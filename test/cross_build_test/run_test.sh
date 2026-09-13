#!/usr/bin/env bash
#
# Runs `bazel <subcommand> [args...]` in the nested test_cross_build module
# and asserts it succeeds.
#
# test_cross_build is a separate Bazel module (its own MODULE.bazel/WORKSPACE,
# local_path_override'd onto this checkout) excluded from this repo's own
# package tree by .bazelignore (see
# https://github.com/bazelbuild/bazel/issues/22208), so a label inside it
# cannot be passed to the expect_build_failure.bzl macros, which build a
# label in this same workspace. This drives a nested `bazel` directly instead.
# The nested `bazel` (and the rationale for it) lives in the shared
# nested_bazel.sh helper this script sources.
#
# Usage: run_test.sh <bazel subcommand> [args...]

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

nested_bazel_setup "rules_scala_cross_build_output_base"
cd test_cross_build

if ! output="$(nested_bazel_run "$@" 2>&1)"; then
  echo "${output}" >&2
  echo "bazel $* failed" >&2
  exit 1
fi
