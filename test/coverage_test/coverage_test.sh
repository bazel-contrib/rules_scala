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

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

target=""
bazel_args=()
expected=""
grep_pattern=""

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

if ! coverage_output="$(nested_bazel_run coverage "${bazel_args[@]}" "${target}" 2>&1)"; then
  echo "Expected \`bazel coverage ${target}\` to succeed, but it failed." >&2
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
    echo "coverage.dat for ${target} does not contain expected line: ${grep_pattern}" >&2
    exit 1
  fi
fi
