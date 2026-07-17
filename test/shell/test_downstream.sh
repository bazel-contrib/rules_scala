#!/usr/bin/env bash
#
# Downstream tests: build a real, independently-maintained external project
# that depends on rules_scala, pointed at *this* checkout instead of its
# pinned released version, to catch consumer-breaking changes before they
# ship.
#
# Every test function here is prefixed with `_` (see test_runner.sh's
# `_skip_test`), so `run_tests` skips them by default -- these clone a large
# external repo and fetch its Maven dependencies, which is slow and
# network-dependent, so they are not yet wired into `.bazelci/presubmit.yml`.
# Run one explicitly with, e.g.:
#
#   RULES_SCALA_TEST_ONLY=_test_downstream_joern ./test_downstream.sh
#
# To promote a test to run automatically in CI: drop its `_` prefix and add a
# task for it (calling this script) to `.bazelci/presubmit.yml`, same as any
# other `test_*.sh` here.

set -euo pipefail

dir="$( cd "${BASH_SOURCE[0]%/*}" && echo "${PWD%/test/shell}" )"
test_source="${dir}/test/shell/${BASH_SOURCE[0]#*test/shell/}"
# shellcheck source=./test_runner.sh
. "${dir}"/test/shell/test_runner.sh

# Clones `consumer_repo` at the exact pinned commit `consumer_sha` (never a
# floating branch tip -- an unrelated upstream break in a consumer shouldn't
# make our CI flaky) and builds `target` against this rules_scala checkout,
# working around whatever friction points a given consumer's Bzlmod setup has
# (e.g. Scala patch-version drift, stale Maven lockfiles, or a consumer's own
# quirks handled via `patch_fn`):
#
#   1. The consumer's exact `scala_version` pin may not match a version this
#      checkout's `third_party` repos carry -- forced via
#      `--repo_env=SCALA_VERSION`, so we build with whatever patch version
#      this checkout actually has rather than the consumer's exact pin.
#   2. `maven_install.json`'s signature can go stale under a different local
#      Bazel version than the consumer was pinned against -- repinned
#      unconditionally rather than trusting the checked-in lockfile.
#
# Args:
#   consumer_repo: git URL to clone.
#   consumer_sha: exact commit SHA to fetch (works even if it's not the tip
#     of any branch GitHub advertises, since GitHub allows fetching any
#     reachable commit by SHA for public repos).
#   scala_version: value to force via --repo_env=SCALA_VERSION (must be one
#     this checkout's third_party repos carry -- see SCALA_VERSIONS in the
#     root MODULE.bazel).
#   target: Bazel target(s) to build in the consumer repo, e.g. "//foo:bar".
#   patch_fn: name of a function (or "") to call, with the consumer repo as
#     cwd, to work around consumer-specific quirks before building.
_downstream_build() {
  local consumer_repo="$1"
  local consumer_sha="$2"
  local scala_version="$3"
  local target="$4"
  local patch_fn="${5:-}"

  local rules_scala_dir="$dir"
  local work_dir
  work_dir="$(mktemp -d)"
  # shellcheck disable=SC2064
  trap "rm -rf '${work_dir}'" RETURN

  git init --quiet "${work_dir}/consumer"
  cd "${work_dir}/consumer"
  git remote add origin "$consumer_repo"
  git fetch --quiet --depth 1 origin "$consumer_sha"
  git checkout --quiet FETCH_HEAD

  cat >>MODULE.bazel <<EOF

local_path_override(
    module_name = "rules_scala",
    path = "${rules_scala_dir}",
)
EOF

  if [[ -n "$patch_fn" ]]; then
    "$patch_fn"
  fi

  REPIN=1 bazel run --repo_env=SCALA_VERSION="$scala_version" @maven//:pin
  # shellcheck disable=SC2086 # intentional word-splitting: `target` may be
  # multiple space-separated Bazel targets.
  bazel build --repo_env=SCALA_VERSION="$scala_version" $target
}

# joern's MODULE.bazel pulls two of its own dependencies (`codepropertygraph`,
# `bazel_tooling`) via `git_override(remote = "git@github.com:...")` -- SSH,
# not HTTPS. Both repos are public, but Bazel's `git_repository` rule shells
# out to the system `git`, which fails outright without an SSH key/known-hosts
# entry ("Host key verification failed"). Rewriting the URL via git's own
# `url.<base>.insteadOf` config -- scoped to this process only, via
# `GIT_CONFIG_GLOBAL` -- makes git use anonymous HTTPS instead, without
# touching joern's MODULE.bazel or this machine's real git config.
_downstream_joern_use_https_git() {
  local rewrite_config
  rewrite_config="$(mktemp)"
  cat >"$rewrite_config" <<'EOF'
[url "https://github.com/"]
    insteadOf = git@github.com:
EOF
  export GIT_CONFIG_GLOBAL="$rewrite_config"
}

# Pinned to the tip of `master` as of 2026-07-16.
_test_downstream_joern() {
  _downstream_build \
    "https://github.com/joernio/joern.git" \
    "7da091d0a6a860a89d411ee04e3a7e696dbdf6b1" \
    "3.7.4" \
    "//semanticcpg:semanticcpg" \
    "_downstream_joern_use_https_git"
}

run_tests "$test_source" "$(get_test_runner "${1:-local}")"
