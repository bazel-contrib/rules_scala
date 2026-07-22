#!/usr/bin/env bash
#
# Shared helpers for driving a *nested* `bazel` invocation from inside an
# `sh_test`: "nested" in the sense of a `bazel` invocation running inside the
# action of a `bazel test`, not nested on disk. Bazel has no native "run bazel
# and assert on the outcome" rule, so the concrete tests (e.g. assert a build
# fails with a given message, or assert a macro emits no ijar) source this file
# and add their own assertions on top of `nested_bazel_run`.
#
# The nested invocation uses its own output base (the parent server holds an
# exclusive lock on its own) while sharing the parent's repository cache so it
# does not re-fetch every external repo from Maven.
#
# Usage (from a script that is run as an `sh_test`):
#   source ".../nested_bazel.sh"
#   nested_bazel_setup rules_scala_<something>_output_base
#   output="$(nested_bazel_run build --repo_env=SCALA_VERSION=2.13.18 //some:target 2>&1)"
#
# This file only defines functions; it is not meant to be executed directly. It
# does not enable shell options (`set -euo pipefail` etc.) -- that is left to the
# sourcing script -- but every function is safe under `set -u`.

# Prints the absolute path of the real source workspace root, so the nested
# `bazel build` operates on the actual sources (and their `.bazelrc`) rather than
# a sandboxed copy.
_nested_bazel_find_workspace() {
  # Case 1: `bazel run` (used for local debugging) exports the source workspace
  # root directly. Prefer it when present.
  if [[ -n "${BUILD_WORKSPACE_DIRECTORY:-}" ]]; then
    printf '%s' "${BUILD_WORKSPACE_DIRECTORY}"
    return
  fi

  # Case 2: under `bazel test` there is no such variable, so locate the workspace
  # via the runfiles tree: `$TEST_SRCDIR/$TEST_WORKSPACE` is the runfiles root and
  # holds a `MODULE.bazel` entry mirroring the source tree.
  local marker="${TEST_SRCDIR:-}/${TEST_WORKSPACE:-_main}/MODULE.bazel"
  if [[ ! -f "${marker}" ]]; then
    echo "Could not determine workspace root." >&2
    return 1
  fi

  # In the runfiles tree that `MODULE.bazel` is normally a symlink pointing back
  # into the real source tree; follow it so we return the source dir, not the
  # runfiles dir. `readlink` yields the target (empty if `marker` is a plain file
  # rather than a symlink, e.g. when runfiles are materialized as real copies).
  local module_file
  module_file="$(readlink "${marker}" 2>/dev/null || true)"
  if [[ -z "${module_file}" ]]; then
    # Not a symlink: the marker itself is the real file.
    module_file="${marker}"
  elif [[ "${module_file}" != /* ]]; then
    # Relative symlink target: resolve it against the marker's directory to get an
    # absolute path.
    module_file="$(cd "$(dirname "${marker}")" && pwd -P)/${module_file}"
  fi

  # The workspace root is the directory containing the resolved `MODULE.bazel`.
  dirname "${module_file}"
}

# Prints the parent Bazel server's output base. We only need it to derive the
# sibling repository-cache path (see `nested_bazel_setup`); we deliberately avoid
# `bazel info`, which would block on the parent's build lock.
_nested_bazel_find_parent_output_base() {
  # Under `bazel test` the runfiles dir (`TEST_SRCDIR`) lives inside the parent
  # output base, at `<output_base>/execroot/<workspace>/.../test.runfiles`.
  # Everything up to (but excluding) the first `/execroot/` is the output base.
  if [[ -n "${TEST_SRCDIR:-}" && "${TEST_SRCDIR}" == *"/execroot/"* ]]; then
    printf '%s' "${TEST_SRCDIR%%/execroot/*}"
    return
  fi

  echo "Could not determine parent Bazel output base." >&2
  return 1
}

# Absolute path of the real source workspace; set by `nested_bazel_setup` for
# callers that need to build paths relative to it.
NESTED_BAZEL_WORKSPACE=""

_nested_bazel_output_base=""
_nested_bazel_real_home=""
_nested_bazel_common_opts=()

# Prepares the environment for nested `bazel` invocations and `cd`s into the real
# source workspace. Call once before any `nested_bazel_run`.
#
# Arg 1: the nested output base directory name (created under /tmp). All nested
# invocations from a single test share it. Under one `bazel test //...` the tests
# then serialize on Bazel's output-base lock (each inner `bazel --batch` waits for
# the lock rather than failing), which keeps the extracted external repos warm and
# avoids multiplying ~1GB of Scala jars across a separate output base per test.
nested_bazel_setup() {
  local output_base_name="${1:?nested_bazel_setup requires an output-base directory name}"

  NESTED_BAZEL_WORKSPACE="$(_nested_bazel_find_workspace)"
  local parent_output_base
  parent_output_base="$(_nested_bazel_find_parent_output_base)"

  _nested_bazel_output_base="/tmp/${output_base_name}"
  mkdir -p "${_nested_bazel_output_base}"
  cd "${NESTED_BAZEL_WORKSPACE}"

  # A `bazel test` runs the test action with a scrubbed `HOME`, so the nested
  # `bazel` would not read the user's `~/.bazelrc` (which may route Maven through
  # a corporate proxy via `--experimental_downloader_config`). Resolve the real
  # home from the passwd database and run with it so it behaves like the user's
  # own `bazel build`. On hosts without such an rc (e.g. CI) this is a no-op.
  _nested_bazel_real_home="$(eval echo "~$(id -un)" 2>/dev/null || true)"

  _nested_bazel_common_opts=()
  # Derive the parent's repository (download) cache from its output base rather
  # than calling `bazel info`: the parent server holds the build lock while this
  # test runs, so contacting it here would block. The layout is
  # <output_user_root>/cache/repos/v1, and the output base is
  # <output_user_root>/<workspace-hash>.
  local repository_cache
  repository_cache="$(dirname "${parent_output_base}")/cache/repos/v1"
  if [[ -d "${repository_cache}" ]]; then
    _nested_bazel_common_opts+=("--repository_cache=${repository_cache}")
  fi
  # Keep the nested build's convenience symlinks out of the workspace so they do
  # not clobber the parent invocation's `bazel-bin` etc.
  _nested_bazel_common_opts+=("--symlink_prefix=${_nested_bazel_output_base}/convenience_symlinks/")
}

# Runs `bazel <subcommand> [args...]` against the nested output base, inserting
# the shared command options right after the subcommand. Forwards the exit code
# and output of `bazel`, so callers can assert on either.
nested_bazel_run() {
  local subcommand="$1"
  shift

  local cmd=(
    bazel
    --batch
    "--output_base=${_nested_bazel_output_base}"
    "${subcommand}"
    "${_nested_bazel_common_opts[@]}"
    "$@"
  )
  if [[ -n "${_nested_bazel_real_home}" && -d "${_nested_bazel_real_home}" ]]; then
    cmd=(env "HOME=${_nested_bazel_real_home}" "${cmd[@]}")
  fi

  # On Windows this script runs under MSYS2 bash, which auto-converts
  # POSIX-path-looking argv entries before exec'ing a native Windows binary
  # like bazel.exe. A bare `//pkg:target` label gets corrupted by this (observed:
  # arrived at Bazel as `/pkg:target`), and so does one embedded in a
  # `--extra_toolchains=//pkg:target` value (observed the same way, e.g.
  # `//scala:minimal_direct_source_deps` -> `/scala:...`) -- but
  # `--output_base=/tmp/...` above *needs* the same conversion to become a real
  # Windows path, so disabling it outright (tried first) broke that instead.
  # MSYS2_ARG_CONV_EXCL excludes args matching a given prefix (semicolon
  # separated), leaving everything else (like /tmp/...) converted as before.
  MSYS2_ARG_CONV_EXCL='//;--extra_toolchains=' "${cmd[@]}"
}
