#!/usr/bin/env bash
#
# Verifies that `bazel run` of a scala_binary fails when JAVABIN is
# overridden to a nonexistent path, since the wrapper script it launches
# through resolves the JVM via JAVABIN.
#
# Usage: scala_binary_override_javabin_test.sh <target>

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

target="${1:?Usage: scala_binary_override_javabin_test.sh <target>}"

nested_bazel_setup "rules_scala_override_javabin_output_base"

if output="$(JAVABIN=/etc/basdf nested_bazel_run run "${target}" 2>&1)"; then
  echo "${output}"
  echo "bazel run ${target} with JAVABIN=/etc/basdf should have failed but passed." >&2
  exit 1
fi
