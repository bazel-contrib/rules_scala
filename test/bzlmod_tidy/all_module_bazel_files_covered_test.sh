#!/usr/bin/env bash
# Fails when the repo's git-tracked MODULE.bazel files diverge from the
# directories hardcoded in test/bzlmod_tidy/BUILD's MODULE_DIRS list (passed
# in as argv), so every newly added MODULE.bazel is guaranteed a matching
# bzlmod_tidy_test target.
#
# Usage: all_module_bazel_files_covered_test.sh <module-dir>...

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"
nested_bazel_setup "rules_scala_bzlmod_tidy_output_base"

cd "${NESTED_BAZEL_WORKSPACE}"

actual="$(git ls-files '**MODULE.bazel' | sort)"
expected="$(
  for dir in "$@"; do
    if [[ "${dir}" == "." ]]; then
      echo "MODULE.bazel"
    else
      echo "${dir}/MODULE.bazel"
    fi
  done | sort
)"

if [[ "${actual}" != "${expected}" ]]; then
  echo "ERROR: test/bzlmod_tidy/BUILD's MODULE_DIRS list is out of sync with" \
    "the repo's tracked MODULE.bazel files." >&2
  echo "--- git ls-files '**MODULE.bazel' ---" >&2
  echo "${actual}" >&2
  echo "--- MODULE_DIRS (expanded) ---" >&2
  echo "${expected}" >&2
  exit 1
fi
