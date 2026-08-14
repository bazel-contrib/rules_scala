#!/usr/bin/env bash
#
# Runs //test/scala_test:custom_reporter -- a scala_test configured with a
# `reporter_class` -- and asserts that reporter actually ran, by checking it
# wrote its `custom_reporter_check` marker into the test's undeclared outputs
# (TEST_UNDECLARED_OUTPUTS_DIR). That marker is an on-disk artifact `bazel test`
# never prints to stdout, so this needs a bespoke sh_test rather than one of the
# stdout-matching expect_build_failure.bzl macros.
#
# --zip_undeclared_test_outputs=false leaves the marker as a plain file under
# test.outputs/ (rather than inside outputs.zip), so the check is a simple
# file-existence test with no unzip step. --nocache_test_results forces the
# reporter to run rather than replaying a cached result.
#
# The nested `bazel test` (and the rationale for it) lives in the shared
# nested_bazel.sh helper this script sources.

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

nested_bazel_setup "rules_scala_custom_reporter_output_base"

nested_bazel_run test //test/scala_test:custom_reporter \
  --nocache_test_results \
  --zip_undeclared_test_outputs=false

testlogs="$(nested_bazel_run info bazel-testlogs)"
marker="${testlogs}/test/scala_test/custom_reporter/test.outputs/custom_reporter_check"

if [[ ! -f "${marker}" ]]; then
  echo "Expected the custom reporter to write ${marker}, but it is absent." >&2
  echo "Contents of the test.outputs directory:" >&2
  ls -la "$(dirname "${marker}")" >&2 || true
  exit 1
fi
