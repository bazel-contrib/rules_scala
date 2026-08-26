#!/usr/bin/env bash
#
# Asserts the Scalac action for `third_party/test/proto` (a self-contained
# bzlmod module, walled off from this workspace via `.bazelignore`) carries the
# expected action label. The signal here is a nested `bazel aquery`'s stdout,
# while `expect_build_failure.bzl`'s macros model a build/test outcome, so this
# uses a custom sh_test instead of one of those macros. The nested `bazel`
# (and the rationale for it) lives in the shared nested_bazel.sh helper this
# script sources.

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

expected="action 'scala @@//:proto'"

nested_bazel_setup "rules_scala_proto_library_action_label_output_base"
cd third_party/test/proto

if ! output="$(nested_bazel_run aquery --include_aspects 'mnemonic("Scalac", //...)' 2>&1)"; then
  echo "aquery failed:" >&2
  echo "${output}" >&2
  exit 1
fi

action="$(grep '^action' <<<"${output}" | head -n 1)"
if [[ "${action}" != "${expected}" ]]; then
  echo "Expected \"${expected}\" but got \"${action}\"" >&2
  exit 1
fi
