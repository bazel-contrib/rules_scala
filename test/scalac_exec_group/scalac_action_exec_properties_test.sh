#!/usr/bin/env bash
#
# Asserts that a `scalac.*` exec_property set on a target actually reaches the
# Scalac action's ExecutionInfo -- that is, that `compile_scala` passes
# `exec_group = "scalac"` to `ctx.actions.run`.
#
# Analysis alone cannot catch a missing `exec_group` there: Bazel would
# silently route the property to the default exec group instead of failing.
# Only `bazel aquery` shows an action's ExecutionInfo -- Starlark's `Action`
# API exposes argv/env/inputs/outputs/mnemonic but not execution info -- so
# this cannot be an analysistest and needs a nested `bazel` invocation.
#
# The nested `bazel` runner (and the rationale for it) lives in the shared
# nested_bazel.sh helper this script sources.
#
# Usage:
#   scalac_action_exec_properties_test.sh <execution-info-substring> <target>...

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

expected="${1:-}"
shift 1 2>/dev/null || true
targets=("$@")

if [[ -z "${expected}" || "${#targets[@]}" -eq 0 ]]; then
  echo "Usage: scalac_action_exec_properties_test.sh <execution-info-substring> <target>..." >&2
  exit 2
fi

# Shares the output base of the other nested-Bazel tests (see
# expect_build_failure.sh): they run at the same Scala version, so the extracted
# external repos stay warm instead of costing another ~1GB. Callers must tag
# this test "exclusive" -- see the BUILD file.
nested_bazel_setup "rules_scala_expect_build_failure_output_base"

# One combined query over all targets rather than one per target: each nested
# `bazel aquery` is expensive.
query=""
for target in "${targets[@]}"; do
  query+="${target} + "
done
query="mnemonic(\"Scalac\", ${query% + })"

if ! output="$(nested_bazel_run aquery "${query}" 2>&1)"; then
  echo "Nested \`bazel aquery ${query}\` failed:" >&2
  echo "${output}" >&2
  exit 1
fi

# Every target contributes exactly one Scalac action, so the number of matching
# ExecutionInfo lines must equal the number of targets. Counting rather than
# pattern-matching is what keeps the combined query strict: a plain match on the
# merged output would still pass if only one of the targets kept the property.
# `|| true` because `grep -c` exits 1 on zero matches, which `set -e` would turn
# into a silent abort before the count below can report it.
actual="$(grep -c "ExecutionInfo:.*${expected}" <<<"${output}" || true)"

if [[ "${actual}" != "${#targets[@]}" ]]; then
  echo "Expected ${#targets[@]} Scalac actions carrying '${expected}' in ExecutionInfo, found ${actual}." >&2
  echo "Targets queried: ${targets[*]}" >&2
  echo "${output}" >&2
  exit 1
fi
