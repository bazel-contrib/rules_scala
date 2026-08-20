#!/usr/bin/env bash
#
# Filtering a specs2 suite down to its one failing example must still write a
# JUnit XML report, and the report must list only that example, not the
# sibling example --test_filter excluded. The nested `bazel test` is expected
# to fail (the filtered example fails), so this can't reuse
# expect_test_failure_test's stdout-only assertions; it needs to read the
# report the same way specs2_test_xml_test.sh does.

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

nested_bazel_setup "rules_scala_specs2_failing_test_xml_output_base"

set +e
nested_bazel_run test \
  --nocache_test_results \
  --test_output=streamed \
  '--test_filter=scalarules.test.junit.specs2.SuiteWithOneFailingTest#specs2 tests::fail$' \
  //test/scala_junit_test:specs2_failing_test
status=$?
set -e
if [[ "${status}" -eq 0 ]]; then
  echo "Expected the nested \`bazel test\` to fail (the filtered example fails), but it succeeded." >&2
  exit 1
fi

report="$(nested_bazel_run info bazel-testlogs)/test/scala_junit_test/specs2_failing_test/test.xml"
if [[ ! -f "${report}" ]]; then
  echo "Expected a JUnit report at ${report}, but it does not exist." >&2
  exit 1
fi
count="$(grep -c -e "testcase name='specs2 tests::fail'" -e "testcase name='specs2 tests::succeed'" "${report}" || true)"
if [[ "${count}" -ne 1 ]]; then
  echo "Expected exactly one testcase in ${report}, found ${count}. Full report:" >&2
  cat "${report}" >&2
  exit 1
fi
