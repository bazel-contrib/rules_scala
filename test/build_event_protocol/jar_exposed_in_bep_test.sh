#!/usr/bin/env bash
#
# Asserts a target's output jar is announced in the Build Event Protocol: builds
# the target with --build_event_text_file and greps the resulting BES file for
# the jar's path. Parameterised so one script backs all the per-rule targets
# (see this package's BUILD).
#
# Args:
#   $1  the //test target label to build.
#   $2  the workspace-relative jar path expected in the BES stream.
#
# The signal is a generated BES file, not a build/test *outcome*, so this is a
# bespoke sh_test rather than an expect_build_failure.bzl macro. The nested
# `bazel` (and the rationale for it) lives in the shared nested_bazel.sh helper
# this script sources.

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

target="${1:?usage: jar_exposed_in_bep_test.sh <target> <expected_jar>}"
expected_jar="${2:?usage: jar_exposed_in_bep_test.sh <target> <expected_jar>}"

nested_bazel_setup "rules_scala_build_event_protocol_output_base"

bes_file="${TEST_TMPDIR:?TEST_TMPDIR must be set}/build_events.txt"
nested_bazel_run build "${target}" "--build_event_text_file=${bes_file}" >/dev/null 2>&1

if ! grep --quiet --fixed-strings "${expected_jar}" "${bes_file}"; then
  echo "Expected jar '${expected_jar}' to appear in the Build Event Protocol for" \
    "${target}, but it did not. BES file:" >&2
  cat "${bes_file}" >&2
  exit 1
fi
