#!/usr/bin/env bash
#
# Runs a nested `bazel <command>` (build/test/coverage) of a target, asserts it
# fails (or, with --expect-success, succeeds), and that the combined output
# contains every expected message and none of the rejected messages.
#
# The nested `bazel` invocation (and the rationale for it) lives in the shared
# nested_bazel.sh helper this script sources.
#
# Usage:
#   expect_build_failure.sh --target <label> \
#       [--command <build|test|coverage>] \
#       [--expect-success] \
#       [--env <KEY=VALUE>]... \
#       [--bazel-arg <flag>]... \
#       [--expect-file <path>]... \
#       [--reject-file <path>]...
#
#   --target          the label to act on.
#   --command         the bazel subcommand to run; defaults to `build`.
#   --expect-success  assert the invocation succeeds; by default it must fail.
#   --env             KEY=VALUE exported into the nested `bazel` client env before
#                     the invocation (e.g. to feed a target's `env_inherit`);
#                     repeatable.
#   --bazel-arg       extra option forwarded to the nested `bazel <command>` (e.g.
#                     `--repo_env=SCALA_VERSION=2.13.18` or `--extra_toolchains=...`);
#                     repeatable.
#   --clean-before-build  run `bazel clean` (no --expunge) against the nested
#                     output base before the real invocation. The caller
#                     (expect_build_success_test) passes this whenever it also
#                     has expect/reject files: unlike a failure, a successful
#                     action can be served from the nested output base's
#                     on-disk cache on a later run of this same test, silently
#                     skipping recompilation and so reprinting no output to
#                     check. `bazel clean` clears that without re-fetching the
#                     external repos the nested output base keeps warm.
#   --expect-file     file whose (newline-stripped) contents must appear in the
#                     output; repeatable.
#   --reject-file     file whose (newline-stripped) contents must NOT appear in the
#                     output; repeatable.
#
# Messages are passed as files rather than inline strings because Bazel subjects
# `sh_test` `args` to Bourne tokenization, which would split messages that
# contain spaces.

set -euo pipefail

# Captured before nested_bazel_setup `cd`s into the workspace, so message-file
# paths passed as runfiles-relative (e.g. via `$(rootpath ...)`) still resolve.
orig_pwd="${PWD}"

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

target=""
command="build"
expect_success="false"
clean_before_build="false"
bazel_args=()
expect_files=()
reject_files=()

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --target)
      target="$2"
      shift 2
      ;;
    --command)
      command="$2"
      shift 2
      ;;
    --expect-success)
      expect_success="true"
      shift
      ;;
    --clean-before-build)
      clean_before_build="true"
      shift
      ;;
    --env)
      # Exported here so it reaches the nested `bazel` client (nested_bazel_run
      # only prepends HOME, preserving the rest of the environment).
      export "${2?--env requires KEY=VALUE}"
      shift 2
      ;;
    --bazel-arg)
      bazel_args+=("$2")
      shift 2
      ;;
    --expect-file)
      expect_files+=("$2")
      shift 2
      ;;
    --reject-file)
      reject_files+=("$2")
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "${target}" ]]; then
  echo "Missing required --target." >&2
  exit 2
fi

# Resolves a message file path, tolerating an absolute path, a path relative to
# the original working directory (before the `cd` in nested_bazel_setup), or one
# relative to the test's runfiles root.
_resolve_message_file() {
  local file="$1"

  local candidate
  for candidate in \
    "${file}" \
    "${orig_pwd}/${file}" \
    "${TEST_SRCDIR:-}/${TEST_WORKSPACE:-}/${file}"; do
    if [[ -f "${candidate}" ]]; then
      printf '%s' "${candidate}"
      return
    fi
  done

  printf '%s' "${file}"
}

nested_bazel_setup "rules_scala_expect_build_failure_output_base"

if [[ "${clean_before_build}" == "true" ]]; then
  nested_bazel_run clean >/dev/null 2>&1
fi

set +e
output="$(nested_bazel_run "${command}" ${bazel_args[@]+"${bazel_args[@]}"} "${target}" 2>&1)"
status=$?
set -e

if [[ "${expect_success}" == "true" && "${status}" -ne 0 ]]; then
  echo "Expected \`bazel ${command}\` of \"${target}\" to succeed, but it failed (exit ${status})." >&2
  echo "${output}" >&2
  exit 1
fi
if [[ "${expect_success}" != "true" && "${status}" -eq 0 ]]; then
  echo "Expected \`bazel ${command}\` of \"${target}\" to fail, but it succeeded." >&2
  echo "${output}" >&2
  exit 1
fi

for expect_file in ${expect_files[@]+"${expect_files[@]}"}; do
  resolved="$(_resolve_message_file "${expect_file}")"
  expected_message="$(tr -d '\n' <"${resolved}")"
  if ! grep --quiet --fixed-strings -- "${expected_message}" <<<"${output}"; then
    echo "Nested \`bazel ${command}\` finished as expected, but output did not contain the expected message." >&2
    echo "Expected (from ${expect_file}): ${expected_message}" >&2
    echo "Output:" >&2
    echo "${output}" >&2
    exit 1
  fi
done

for reject_file in ${reject_files[@]+"${reject_files[@]}"}; do
  resolved="$(_resolve_message_file "${reject_file}")"
  rejected_message="$(tr -d '\n' <"${resolved}")"
  if grep --quiet --fixed-strings -- "${rejected_message}" <<<"${output}"; then
    echo "Nested \`bazel ${command}\` finished as expected, but output contained a message that should be absent." >&2
    echo "Rejected (from ${reject_file}): ${rejected_message}" >&2
    echo "Output:" >&2
    echo "${output}" >&2
    exit 1
  fi
done
