#!/usr/bin/env bash
#
# Runs //test:JunitTestWithDeps and asserts the generated JUnit XML report lists
# a <testcase> for the test's methods. `bazel test` only writes this test.xml to
# disk -- it never reaches stdout -- so, unlike the discovered-classes and
# --test_filter checks (now expect_test_success_test targets that match on the
# runner's stdout), this one reads the artifact directly and so needs a bespoke
# sh_test rather than one of the expect_build_failure.bzl macros.
#
# The nested `bazel test` (and the rationale for it) lives in the shared
# nested_bazel.sh helper this script sources.

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

nested_bazel_setup "rules_scala_junit_xml_output_base"

nested_bazel_run test //test:JunitTestWithDeps

testlogs="$(nested_bazel_run info bazel-testlogs)"
report="${testlogs}/test/JunitTestWithDeps/test.xml"

expected=(
  "testcase name='hasCompileTimeDependencies'"
  "testcase name='hasRuntimeDependencies'"
)
for testcase in "${expected[@]}"; do
  if ! grep -qF "${testcase}" "${report}"; then
    echo "Expected <${testcase}> in ${report}, but it was not found. Full report:" >&2
    cat "${report}" >&2
    exit 1
  fi
done
