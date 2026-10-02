#!/usr/bin/env bash
#
# Regression test: jacoco_metadata.txt must end up in a coverage-enabled test
# target's runfiles tree. `phase_default_info` collects runfiles only from
# phase results that carry a `runfiles` attribute, by design. So
# `_write_executable_non_windows` (scala/private/phases/phase_write_executable.bzl)
# must return `struct(runfiles = depset([jacoco_metadata_file]))` from its
# jacoco branch; returning a bare list instead drops the file from that
# collection unintentionally, and it is never even built.
#
# Usage:
#   jacoco_metadata_runfiles_test.sh --target <label> --instrumented-jar <bazel-bin-relative path>

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

target=""
instrumented_jar=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --target)
    target="$2"
    shift 2
    ;;
  --instrumented-jar)
    instrumented_jar="$2"
    shift 2
    ;;
  *)
    echo "Unknown arg: $1" >&2
    exit 2
    ;;
  esac
done

if [[ -z "${target}" ]] || [[ -z "${instrumented_jar}" ]]; then
  echo "Usage: jacoco_metadata_runfiles_test.sh --target <label> --instrumented-jar <path>" >&2
  exit 2
fi

nested_bazel_setup rules_scala_coverage_output_base

if ! build_output="$(nested_bazel_run build --collect_code_coverage "${target}" 2>&1)"; then
  echo "Expected \`bazel build --collect_code_coverage ${target}\` to succeed, but it failed." >&2
  echo "${build_output}" >&2
  exit 1
fi

bazel_bin="$(nested_bazel_run info bazel-bin 2>/dev/null)"
# //pkg:name -> pkg/name, matching Bazel's bazel-bin layout.
target_relpath="${target#//}"
target_relpath="${target_relpath/://}"
metadata_file="${bazel_bin}/${target_relpath}.runfiles/_main/${target_relpath}.jacoco_metadata.txt"

if [[ ! -s "${metadata_file}" ]]; then
  echo "Expected ${target}'s runfiles tree to contain a non-empty ${target_relpath}.jacoco_metadata.txt, but ${metadata_file} is missing or empty." >&2
  exit 1
fi

# An instrumented jar keeps each original class next to it as
# `<class>.uninstrumented`.
if ! grep -qx -- "${instrumented_jar}" "${metadata_file}"; then
  echo "Expected ${metadata_file} to list ${instrumented_jar}; it lists:" >&2
  cat "${metadata_file}" >&2
  exit 1
fi
listing="$(jar tf "${bazel_bin}/${instrumented_jar}")"
if [[ "${listing}" != *".class.uninstrumented"* ]]; then
  echo "Expected ${instrumented_jar} to be JaCoCo-instrumented (to hold .class.uninstrumented entries); it holds only plain classes." >&2
  exit 1
fi
