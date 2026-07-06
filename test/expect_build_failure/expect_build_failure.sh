#!/usr/bin/env bash
#
# Verifies that `bazel build` of a target fails, and that the combined build
# output contains every expected message and none of the rejected messages.
#
# The nested `bazel build` (and the rationale for it) lives in the shared
# nested_bazel.sh helper this script sources.
#
# Usage:
#   expect_build_failure.sh --target <label> \
#       [--build-arg <flag>]... \
#       [--expect-file <path>]... \
#       [--reject-file <path>]...
#
#   --target       the label to build; the build is expected to fail.
#   --build-arg    extra option forwarded to the nested `bazel build` (e.g.
#                  `--repo_env=SCALA_VERSION=2.13.18`); repeatable.
#   --expect-file  file whose (newline-stripped) contents must appear in the
#                  build output; repeatable.
#   --reject-file  file whose (newline-stripped) contents must NOT appear in the
#                  build output; repeatable.
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
build_args=()
expect_files=()
reject_files=()

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --target)
      target="$2"
      shift 2
      ;;
    --build-arg)
      build_args+=("$2")
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

output="$(nested_bazel_run build ${build_args[@]+"${build_args[@]}"} "${target}" 2>&1)" && {
  echo "Expected build of \"${target}\" to fail, but it succeeded." >&2
  echo "${output}" >&2
  exit 1
}

for expect_file in ${expect_files[@]+"${expect_files[@]}"}; do
  resolved="$(_resolve_message_file "${expect_file}")"
  expected_message="$(tr -d '\n' <"${resolved}")"
  if ! grep --quiet --fixed-strings -- "${expected_message}" <<<"${output}"; then
    echo "Build failed as expected, but output did not contain the expected message." >&2
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
    echo "Build failed as expected, but output contained a message that should be absent." >&2
    echo "Rejected (from ${reject_file}): ${rejected_message}" >&2
    echo "Output:" >&2
    echo "${output}" >&2
    exit 1
  fi
done
