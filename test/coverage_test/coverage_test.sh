#!/usr/bin/env bash
#
# Asserts that a nested `bazel coverage` of a target succeeds and that the
# resulting coverage.dat matches an expectation: either byte-identical to a
# checked-in file, or containing a given line.
#
# `bazel coverage` can't run from inside a plain sh_test action: the sandbox
# can't shell out to the Bazel that started it. The nested `bazel` (and the
# rationale for it) lives in the shared nested_bazel.sh helper this script
# sources.
#
# Usage:
#   coverage_test.sh --target <label> [--bazel-arg <flag>]...
#                     (--expected <workspace-relative path> | --grep <pattern>)
#                     [--reject-grep <pattern>] [--expected-output <pattern>]

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

target=""
bazel_args=()
expected=""
grep_pattern=""
reject_pattern=""
expected_output_pattern=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --target)
    target="$2"
    shift 2
    ;;
  --bazel-arg)
    bazel_args+=("$2")
    shift 2
    ;;
  --expected)
    expected="$2"
    shift 2
    ;;
  --grep)
    grep_pattern="$2"
    shift 2
    ;;
  --reject-grep)
    reject_pattern="$2"
    shift 2
    ;;
  --expected-output)
    expected_output_pattern="$2"
    shift 2
    ;;
  *)
    echo "Unknown arg: $1" >&2
    exit 2
    ;;
  esac
done

if [[ -z "${target}" ]] ||
  { [[ -z "${expected}" ]] && [[ -z "${grep_pattern}" ]]; } ||
  { [[ -n "${expected}" ]] && [[ -n "${grep_pattern}" ]]; }; then
  echo "Usage: coverage_test.sh --target <label> [--bazel-arg <flag>]... (--expected <path> | --grep <pattern>)" >&2
  exit 2
fi

nested_bazel_setup rules_scala_coverage_output_base

if [[ -n "${expected_output_pattern}" ]]; then
  # A cached instrumenter action prints nothing on a later run, so an
  # --expected-output check needs a clean output base to force re-execution
  # (same reasoning as expect_build_failure.sh's --clean-before-build).
  nested_bazel_run clean >/dev/null 2>&1
fi

if ! coverage_output="$(nested_bazel_run coverage "${bazel_args[@]}" "${target}" 2>&1)"; then
  echo "Expected \`bazel coverage ${target}\` to succeed, but it failed." >&2
  echo "${coverage_output}" >&2
  exit 1
fi

if [[ -n "${expected_output_pattern}" ]] && ! grep -q "${expected_output_pattern}" <<<"${coverage_output}"; then
  echo "\`bazel coverage ${target}\` output does not contain expected text: ${expected_output_pattern}" >&2
  echo "${coverage_output}" >&2
  exit 1
fi

testlogs_dir="$(nested_bazel_run info bazel-testlogs 2>/dev/null)"
# //pkg:name -> pkg/name, matching Bazel's bazel-testlogs layout.
target_relpath="${target#//}"
target_relpath="${target_relpath/://}"
coverage_dat="${testlogs_dir}/${target_relpath}/coverage.dat"

if [[ -n "${expected}" ]]; then
  if ! diff "${expected}" "${coverage_dat}"; then
    echo "coverage.dat for ${target} does not match ${expected}" >&2
    exit 1
  fi
else
  if ! grep -q "${grep_pattern}" "${coverage_dat}"; then
    echo "coverage.dat for ${target} does not contain expected text: ${grep_pattern}" >&2
    exit 1
  fi
fi

if [[ -n "${reject_pattern}" ]]; then
  reject_grep_status=0
  grep -q -- "${reject_pattern}" "${coverage_dat}" || reject_grep_status="$?"
  if [[ "${reject_grep_status}" -eq 0 ]]; then
    echo "coverage.dat for ${target} contains rejected text: ${reject_pattern}" >&2
    exit 1
  elif [[ "${reject_grep_status}" -gt 1 ]]; then
    echo "grep failed (exit ${reject_grep_status}) while checking for rejected text: ${reject_pattern}" >&2
    exit 1
  fi
fi
