#!/usr/bin/env bash
#
# Builds the diagnostics_reporter fixtures under <toolchain> (letting the
# intentionally-broken ones fail with `--keep_going`), then runs the
# diagnostics_reporter_test verifier against the resulting
# *.diagnosticsproto files it should have produced.
#
# The nested `bazel build`/`bazel run` (and the rationale for it) lives in the
# shared nested_bazel.sh helper this script sources.
#
# Usage:
#   diagnostic_proto_files_test.sh <toolchain> <fixture-target>...

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

toolchain="${1:?Usage: diagnostic_proto_files_test.sh <toolchain> <fixture-target>...}"
shift
fixtures=("$@")
if [[ "${#fixtures[@]}" -eq 0 ]]; then
  echo "Usage: diagnostic_proto_files_test.sh <toolchain> <fixture-target>..." >&2
  exit 2
fi

nested_bazel_setup "rules_scala_diagnostics_reporter_output_base"

# Swallowing this build's exit code doesn't make the check blind: the
# verifier below asserts each fixture's specific diagnostic message, so if a
# fixture stopped failing (or reporting) the way it's supposed to, the
# expected message just wouldn't be found and the verifier would fail.
nested_bazel_run build --keep_going --extra_toolchains="${toolchain}" "${fixtures[@]}" || true

bazel_bin="$(nested_bazel_run info bazel-bin)"
diagnostics_output="${bazel_bin}/test/diagnostics_reporter"

nested_bazel_run run //test/diagnostics_reporter:diagnostics_reporter_test -- "${diagnostics_output}"
