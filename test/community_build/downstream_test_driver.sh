#!/usr/bin/env bash
#
# Nested-bazel driver for `downstream_test`: runs `bazel test` inside a
# Bazel-fetched external consumer repo (see downstream_repository.bzl),
# against *this* rules_scala checkout via the `local_path_override` that
# repository rule already wrote into the consumer's MODULE.bazel.
#
# Usage: downstream_test_driver.sh --marker-rootpath <path> --scala-version <v> \
#   --output-base-name <name> [--extra-bazel-flags <flags>] -- <target-pattern>...
#
# Named flags because Bazel/rules_shell silently drops or mangles blank
# `args` entries -- same convention as test/expect_build_failure/expect_build_failure.sh.

set -euo pipefail

marker_rootpath=""
scala_version=""
output_base_name=""
extra_bazel_flags=""
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --marker-rootpath)
      marker_rootpath="$2"
      shift 2
      ;;
    --scala-version)
      scala_version="$2"
      shift 2
      ;;
    --output-base-name)
      output_base_name="$2"
      shift 2
      ;;
    --extra-bazel-flags)
      extra_bazel_flags="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done
targets=("$@")

srcdir="${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}"
workspace="${TEST_WORKSPACE:-_main}"

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${srcdir}/${workspace}/test/expect_build_failure/nested_bazel.sh"

marker="${srcdir}/${marker_rootpath}"
if [[ ! -f "${marker}" && "${marker_rootpath}" == external/* ]]; then
  # Modern runfiles trees (the --legacy_external_runfiles=false default)
  # place cross-repo runfiles directly under the runfiles root, without the
  # "external/" segment that $(rootpath) still includes.
  marker="${srcdir}/${marker_rootpath#external/}"
fi
if [[ ! -f "${marker}" ]]; then
  echo "Could not find marker file at ${marker}" >&2
  exit 1
fi

# The marker is a symlink back into the real, writable, Bazel-fetched
# external repo (same trick nested_bazel.sh uses to find *our* real
# workspace) -- follow it to get the consumer's actual root, two directories
# up from `_bazel_native_marker/marker.txt`.
resolved="$(readlink "${marker}" 2>/dev/null || true)"
if [[ -z "${resolved}" ]]; then
  resolved="${marker}"
elif [[ "${resolved}" != /* ]]; then
  resolved="$(cd "$(dirname "${marker}")" && pwd -P)/${resolved}"
fi
fetched_dir="$(dirname "$(dirname "${resolved}")")"

# Copy out of the fetched location (physically inside *our own* output_base,
# under external/) into a plain scratch dir before running anything there:
# a nested bazel invocation operating on a source tree nested inside another
# Bazel's own output_base hits confusing canonical-repository-name
# resolution failures that a tree living outside any Bazel-managed
# directory (like this copy) does not.
consumer_dir="/tmp/${output_base_name}_src"
rm -rf "${consumer_dir}"
cp -R "${fetched_dir}" "${consumer_dir}"
chmod -R u+w "${consumer_dir}"

# This script is itself running inside a bazel test action's runfiles tree,
# so Bazel's runfiles-library env vars (RUNFILES_DIR, JAVA_RUNFILES, etc.)
# point at *this* test's own runfiles. Left set, they leak into the nested
# `bazel run`/`bazel test` below and confuse any runfiles-library-using
# sh_binary the consumer's build spawns (e.g. rules_jvm_external's `pin`,
# which resolves its own data file via `$(rlocationpath)`) into looking for
# its runfiles in *our* tree instead of its own -- which is exactly why the
# repin step below used to fail silently (see the FIXME it used to carry).
# Clearing them lets each nested invocation's own runfiles bootstrap work
# normally.
unset RUNFILES_DIR RUNFILES_MANIFEST_FILE RUNFILES_MANIFEST_ONLY JAVA_RUNFILES

# Replicates nested_bazel_setup's body, minus its workspace-finding (which
# always resolves *our own* tree, not a fetched consumer's).
NESTED_BAZEL_WORKSPACE="${consumer_dir}"
parent_output_base="$(_nested_bazel_find_parent_output_base)"
_nested_bazel_output_base="/tmp/${output_base_name}"
mkdir -p "${_nested_bazel_output_base}"
cd "${NESTED_BAZEL_WORKSPACE}"
_nested_bazel_real_home="$(eval echo "~$(id -un)" 2>/dev/null || true)"
_nested_bazel_common_opts=()
repository_cache="$(dirname "${parent_output_base}")/cache/repos/v1"
if [[ -d "${repository_cache}" ]]; then
  _nested_bazel_common_opts+=("--repository_cache=${repository_cache}")
fi
_nested_bazel_common_opts+=("--symlink_prefix=${_nested_bazel_output_base}/convenience_symlinks/")

# Some consumers' own build/test actions write outside the sandbox: joern's
# javasrc2cpg to `~/.shiftleft`, and its codepropertygraph dep's run_codegen
# genrule shells out to scalafmt's dynamic Coursier downloader, which writes
# to `~/.cache/coursier`. Harmless no-op for consumers that don't need it, so
# it's unconditional rather than per-consumer configuration.
if [[ -n "${_nested_bazel_real_home}" ]]; then
  mkdir -p "${_nested_bazel_real_home}/.shiftleft" "${_nested_bazel_real_home}/.cache/coursier"
  _nested_bazel_common_opts+=(
    "--sandbox_writable_path=${_nested_bazel_real_home}/.shiftleft"
    "--sandbox_writable_path=${_nested_bazel_real_home}/.cache/coursier"
  )
fi

# Some consumers (e.g. joern) `git_override` their own deps via
# `git@github.com:...` (SSH), which fails without an SSH key/known-hosts
# entry even though the repos are public (worse, some CI images don't even
# have an `ssh` binary to fail cleanly with -- "cannot run ssh: No such file
# or directory"). Rewrite SSH GitHub URLs to anonymous HTTPS for every git
# operation this nested invocation makes -- harmless no-op for consumers
# that don't need it. Via XDG_CONFIG_HOME rather than GIT_CONFIG_GLOBAL: the
# latter needs git 2.32+ and some CI images' older git predates it (confirmed:
# it fetched one of joern's two git_override deps and silently ignored it for
# the other); git has honored $XDG_CONFIG_HOME/git/config since ~2012, and it
# applies *alongside* (not instead of) the user's own ~/.gitconfig, so this
# never touches a real dev machine's dotfiles.
xdg_config_home="/tmp/${output_base_name}_xdg_config"
mkdir -p "${xdg_config_home}/git"
cat >"${xdg_config_home}/git/config" <<'EOF'
[url "https://github.com/"]
    insteadOf = git@github.com:
EOF
export XDG_CONFIG_HOME="${xdg_config_home}"
_nested_bazel_common_opts+=("--repo_env=XDG_CONFIG_HOME=${xdg_config_home}")

# bazelisk always prepends the directory of its already-resolved binary
# (a path through its download cache, e.g. .../bazelisk/downloads/sha256/...)
# to PATH before spawning the real `bazel` (core.go's prependDirToPathList,
# unconditional, no opt-out) -- that's *why* --test_env=PATH is needed at all
# (see the sibling fix in expect_build_failure-land), so a nested `bazel`
# reuses the *same* version as the outer invocation. That's right for
# testing this same repo, but wrong here: we need the *consumer's* pinned
# version (e.g. joern's 9.1.0), not rules_scala's own. Filter out that one
# entry (wherever it lands -- not necessarily first: a leading "." shows up
# ahead of it in some environments) by content rather than position, so
# bazelisk re-resolves from the consumer's .bazelversion instead, keeping
# the rest of PATH (wherever this environment actually keeps its
# bazelisk/bazel) intact.
new_path=""
IFS=':' read -ra path_entries <<<"${PATH}"
for entry in "${path_entries[@]}"; do
  case "${entry}" in
    */bazelisk/downloads/*) continue ;;
  esac
  new_path="${new_path:+${new_path}:}${entry}"
done
PATH="${new_path}"

if ! command -v bazel >/dev/null; then
  echo "No 'bazel' on PATH inside the test action. This usually means the" >&2
  echo "test was run without --test_env=PATH, so it got Bazel's static" >&2
  echo "action PATH instead of your shell's. Rerun as:" >&2
  echo "  bazel test --test_env=PATH ${TEST_TARGET:-<this target>}" >&2
  exit 1
fi

REPIN=1 nested_bazel_run run --repo_env=SCALA_VERSION="${scala_version}" @maven//:pin

# Sanity check: confirm every lockfile the consumer's MODULE.bazel declares
# (not just a hardcoded "maven_install.json" at the root -- e.g. dicer's
# lives at "bazel:maven_install.json" instead) actually exists, in case a
# consumer's own maven.install() ever silently no-ops on repin.
grep -oE 'lock_file = "//[^"]*"' MODULE.bazel | sed -E 's/lock_file = "(.*)"/\1/' | while IFS= read -r lock_label; do
  # //bazel:maven_install.json -> bazel/maven_install.json
  # //:maven_install.json -> maven_install.json (root package)
  slash="/"
  lockfile="${lock_label#//}"
  lockfile="${lockfile/:/${slash}}"
  lockfile="${lockfile#/}"
  if [[ ! -s "${lockfile}" ]]; then
    echo "${lockfile} missing (or empty) after repin -- treating as a real failure" >&2
    exit 1
  fi
done

# shellcheck disable=SC2086 # intentional word-splitting: extra_bazel_flags
# and targets are each meant to expand to multiple words/patterns.
nested_bazel_run test --test_output=errors --repo_env=SCALA_VERSION="${scala_version}" \
  ${extra_bazel_flags} -- "${targets[@]}"
