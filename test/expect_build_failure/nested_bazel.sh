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
_nested_bazel_symlink_prefix=""
_nested_bazel_lane=""
_nested_bazel_lock_dir=""

# Bazel's own output-base lock covers exactly one `bazel` invocation, so two
# tests sharing a lane (see `nested_bazel_setup`'s `lane` argument) can still
# each run one invocation at a time in the gap between another test's two
# separate invocations -- e.g. `expect_build_failure.sh` runs `clean` then
# `build` as two calls when it needs a guaranteed fresh build (its
# --clean-before-build), and a sibling's `build` landing in that gap would
# make this test read the sibling's fresh output instead of its own. This
# lock covers every `nested_bazel_run` call for a lane (see there), and a
# caller that needs several calls to stay uninterrupted as one unit (like the
# clean+build pair above) acquires it itself first so those calls see it
# already held and skip their own acquire/release.
#
# Whether contending for it actually costs a wait depends on the lane_lock
# amount each platform sets in .bazelrc: on Linux/Windows it is 1, so Bazel's
# own scheduler already runs same-lane tests one at a time, and acquiring this
# lock there is one instant, uncontended mkdir/rmdir pair every time. On
# macOS it is 1000 (a deliberate trade against a Bazel scheduler issue,
# bazelbuild/bazel#18153, where a scarce resource delays every unrelated test
# scheduled alongside it, whatever that test's own resource needs are), so
# same-lane tests there really do run at the same time, and this lock is what
# keeps their nested `bazel` calls from interleaving.
#
# mkdir is the mutex primitive here because it is atomic and available in
# every POSIX shell this runs under (Linux, macOS, and Windows' MSYS2 bash);
# flock ships only as part of Linux's util-linux package. The lock directory
# holds the acquiring process's PID: a Bazel test-timeout kill (SIGKILL, which
# no trap can run cleanup for) can leave the directory behind, and the next
# acquirer clears it once `kill -0` on that PID says the process is gone,
# rather than waiting on a lock nobody will ever release. The same kill can
# also land between the `mkdir` and the `pid` write below, leaving an empty
# directory that a PID check alone could never call stale; a run of
# consecutive empty reads clears that case too, since a live acquirer always
# writes its pid within the same instant it creates the directory.
_nested_bazel_acquire_lane_lock() {
  local lane="${1:?_nested_bazel_acquire_lane_lock requires a lane}"
  local lock_dir="/tmp/rules_scala_expect_build_failure_lane${lane}.lock"
  local empty_pid_iterations=0
  while true; do
    if mkdir "${lock_dir}" 2>/dev/null; then
      _nested_bazel_lock_dir="${lock_dir}"
      echo "$$" >"${_nested_bazel_lock_dir}/pid"
      return
    fi

    local holder_pid
    holder_pid="$(cat "${lock_dir}/pid" 2>/dev/null || true)"

    local stale="false"
    if [[ -z "${holder_pid}" ]]; then
      # A directory with no pid file yet is indistinguishable from a holder
      # still between its `mkdir` and its `pid` write, a few instructions
      # away -- unless it stays empty well past that, which only happens if
      # a kill landed in that exact window and left it behind for good.
      empty_pid_iterations=$((empty_pid_iterations + 1))
      if ((empty_pid_iterations >= 20)); then
        stale="true"
      fi
    else
      empty_pid_iterations=0
      if ! kill -0 "${holder_pid}" 2>/dev/null; then
        stale="true"
      fi
    fi

    if [[ "${stale}" == "true" ]]; then
      # Re-read right before removing: the holder this pass called dead or
      # abandoned may since have been cleared and replaced by a new, live
      # one, and deleting the directory out from under that new holder
      # would be worse than the stale lock this is meant to clear.
      if [[ "$(cat "${lock_dir}/pid" 2>/dev/null || true)" == "${holder_pid}" ]]; then
        # rmdir alone fails silently here: the directory holds the "pid" file,
        # so it's never empty.
        rm -rf "${lock_dir}" 2>/dev/null || true
      fi
      continue
    fi

    sleep 0.1
  done
}

# Idempotent: safe to call whether or not a lock is held (also called from the
# EXIT trap `nested_bazel_setup` installs, so a failure between acquire and the
# caller's own release still frees the lock for the next test).
_nested_bazel_release_lane_lock() {
  if [[ -n "${_nested_bazel_lock_dir}" ]]; then
    rm -f "${_nested_bazel_lock_dir}/pid"
    rmdir "${_nested_bazel_lock_dir}" 2>/dev/null || true
    _nested_bazel_lock_dir=""
  fi
}

# Prepares the environment for nested `bazel` invocations and `cd`s into the real
# source workspace. Call once before any `nested_bazel_run`.
#
# Arg 1: the nested output base directory name (created under /tmp). Every
# caller that passes the same name shares that output base and its lock (each
# inner `bazel --batch` waits for the lock rather than failing), which keeps
# the extracted external repos warm and avoids multiplying ~1GB of Scala jars
# across a separate output base per test.
#
# Arg 2: optional lane number. `expect_build_failure.sh` passes one (see its
# --lane) because several of its tests can share the same output-base name
# above; `nested_bazel_run` then takes the matching lane lock around every
# call, so their nested `bazel` calls never interleave. A caller that has the
# output base to itself (like this file's other sourcing scripts) omits this
# argument and pays no locking cost.
_nested_bazel_home_hint() {
  if [[ -n "${RULES_SCALA_NESTED_BAZEL_USE_REAL_HOME:-}" ]]; then
    return
  fi
  echo "note: the nested \`bazel\` ran with a scrubbed HOME, so your ~/.bazelrc was" >&2
  echo "      ignored. If it carries settings the build needs (a download proxy, for" >&2
  echo "      instance), re-run bazel test with --nocache_test_results and" >&2
  echo "      --test_env=RULES_SCALA_NESTED_BAZEL_USE_REAL_HOME=1." >&2
}

nested_bazel_setup() {
  local output_base_name="${1:?nested_bazel_setup requires an output-base directory name}"
  _nested_bazel_lane="${2:-}"

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
  # Any failure below may be the missing rc rather than the code under test, and
  # the reader has no way to guess that, so say it on every failing exit.
  #
  # Also releases the lane lock unconditionally on this EXIT: `set -e` exits
  # the script the instant anything between acquiring the lock and the
  # caller's own release call returns non-zero, skipping that release call.
  # This trap is what actually frees the lane for every later test in that
  # case.
  trap '_nested_bazel_status=$?; _nested_bazel_release_lane_lock; if [[ "${_nested_bazel_status}" -ne 0 ]]; then _nested_bazel_home_hint; fi' EXIT

  # Opt-in: the user's rc is not a declared input of the test, so reading it by
  # default would let a cached result depend on a file outside the repo. CI stays
  # hermetic; a developer who needs the rc sets the variable.
  _nested_bazel_real_home=""
  if [[ -n "${RULES_SCALA_NESTED_BAZEL_USE_REAL_HOME:-}" ]]; then
    _nested_bazel_real_home="$(eval echo "~$(id -un)" 2>/dev/null || true)"
  fi

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
  # not clobber the parent invocation's `bazel-bin` etc. Not added to
  # `_nested_bazel_common_opts`: `bazel query` (unlike build/test/coverage/
  # info/cquery/aquery) produces no such symlinks and rejects this flag
  # outright, so `nested_bazel_run` adds it for every other subcommand only.
  _nested_bazel_symlink_prefix="${_nested_bazel_output_base}/convenience_symlinks/"
}

# Runs `bazel <subcommand> [args...]` against the nested output base, inserting
# the shared command options right after the subcommand. Forwards the exit code
# and output of `bazel`, so callers can assert on either.
#
# Takes the lane lock (see `nested_bazel_setup`'s `lane` argument) around this
# one call when no one holds it yet, and releases it again right after --
# reentrant, so a caller that already took the lock itself (to span more than
# this one call) keeps holding it across this call instead of losing it here.
nested_bazel_run() {
  local subcommand="$1"
  shift

  local acquired_lock_here="false"
  if [[ -n "${_nested_bazel_lane}" && -z "${_nested_bazel_lock_dir}" ]]; then
    _nested_bazel_acquire_lane_lock "${_nested_bazel_lane}"
    acquired_lock_here="true"
  fi

  local cmd=(
    bazel
    --batch
    "--output_base=${_nested_bazel_output_base}"
    "${subcommand}"
    "${_nested_bazel_common_opts[@]}"
  )
  if [[ "${subcommand}" != "query" ]]; then
    cmd+=("--symlink_prefix=${_nested_bazel_symlink_prefix}")
  fi
  cmd+=("$@")
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
  # `labels(` is here for the same reason as `--extra_toolchains=`: a `query`
  # call passes a `labels(srcs, //pkg:target)` argument with a `//pkg:target`
  # label embedded past the start of the string, not verified on a real
  # Windows run but following the same corruption pattern already observed.
  MSYS2_ARG_CONV_EXCL='//;--extra_toolchains=;labels(' "${cmd[@]}"
  local status=$?

  if [[ "${acquired_lock_here}" == "true" ]]; then
    _nested_bazel_release_lane_lock
  fi
  return "${status}"
}
