#!/usr/bin/env bash
#
# Asserts on the generated JUnit XML report for a specs2 suite: it lists a
# <testcase> per example, and --test_filter narrows which ones appear. Like
# junit_generates_xml_logs_test.sh, this is an on-disk artifact bazel test never
# prints to stdout, so it needs a bespoke sh_test rather than one of the
# expect_build_failure.bzl macros.

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

nested_bazel_setup "rules_scala_specs2_test_xml_output_base"

report="$(nested_bazel_run info bazel-testlogs)/test/Specs2Tests/test.xml"

assert_testcase_count() {
  local expected_count="$1"
  if [[ ! -f "${report}" ]]; then
    echo "Expected a JUnit report at ${report}, but it does not exist." >&2
    exit 1
  fi
  local count
  count="$(grep -c -e "testcase name='specs2 tests::run smoothly in bazel'" -e "testcase name='specs2 tests::not run smoothly in bazel'" "${report}" || true)"
  if [[ "${count}" -ne "${expected_count}" ]]; then
    echo "Expected ${expected_count} testcase(s) in ${report}, found ${count}. Full report:" >&2
    cat "${report}" >&2
    exit 1
  fi
}

nested_bazel_run test \
  --nocache_test_results \
  '--test_filter=scalarules.test.junit.specs2.JunitSpecs2Test#' \
  //test:Specs2Tests
assert_testcase_count 2

nested_bazel_run test \
  --nocache_test_results \
  '--test_filter=scalarules.test.junit.specs2.JunitSpecs2Test#specs2 tests::run smoothly in bazel$' \
  //test:Specs2Tests
assert_testcase_count 1
