#!/usr/bin/env bash
#
# Verifies that building all_lib under the default toolchain (semanticdb not
# enabled) produces no .semanticdb files under the target's output dir, and
# that all_lib.jar does not bundle any.
#
# Usage:
#   no_semanticdb_test.sh

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

nested_bazel_setup "rules_scala_semanticdb_output_base"

bazel_bin="$(nested_bazel_run info bazel-bin 2>/dev/null)"
target_out="${bazel_bin}/test/semanticdb"

# The nested output base is reused (and kept warm) across semanticdb sh_tests,
# so target_out may still hold .semanticdb files bundled by an earlier,
# differently-toolchained run against the same output base.
rm -rf "${target_out}"

if ! build_output="$(nested_bazel_run build //test/semanticdb:all_lib 2>&1)"; then
  echo "Expected build of //test/semanticdb:all_lib to succeed." >&2
  echo "${build_output}" >&2
  exit 1
fi

if [[ "$(find "${target_out}" -type f -name '*.semanticdb' | wc -l)" -gt 0 ]]; then
  echo "Error: Semanticdb files erroneously found in target output" >&2
  exit 1
fi

jar="${target_out}/all_lib.jar"
jar_listing="$(jar tf "${jar}")"
for f in A.scala.semanticdb B.scala.semanticdb; do
  if printf '%s\n' "${jar_listing}" | grep -qF "${f}"; then
    echo "Error: Semanticdb included in jar ${jar}, but wasn't expected to be" >&2
    exit 1
  fi
done
