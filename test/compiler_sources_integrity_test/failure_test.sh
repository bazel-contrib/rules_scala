#!/usr/bin/env bash
#
# Builds //... in the nested test/compiler_sources_integrity module under a
# given SCALA_VERSION and asserts the build fails, with every --expect
# substring present in the combined output.
#
# See success_test.sh for why this drives a nested `bazel` directly instead
# of using the expect_build_failure.bzl macros.
#
# Usage:
#   failure_test.sh --scala-version VERSION --expect MESSAGE [--expect MESSAGE]...

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

scala_version=""
expected=()
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --scala-version)
      scala_version="$2"
      shift 2
      ;;
    --expect)
      expected+=("$2")
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "${scala_version}" || "${#expected[@]}" -eq 0 ]]; then
  echo "usage: failure_test.sh --scala-version VERSION --expect MESSAGE [--expect MESSAGE]..." >&2
  exit 2
fi

nested_bazel_setup "rules_scala_compiler_sources_integrity_output_base"
cd test/compiler_sources_integrity

if output="$(nested_bazel_run build "--repo_env=SCALA_VERSION=${scala_version}" //... 2>&1)"; then
  echo "${output}" >&2
  echo "build under SCALA_VERSION=${scala_version} did not fail" >&2
  exit 1
fi

for message in "${expected[@]}"; do
  if ! grep --quiet --fixed-strings "${message}" <<<"${output}"; then
    echo "${output}" >&2
    echo "error message did not contain \"${message}\"" >&2
    exit 1
  fi
done
