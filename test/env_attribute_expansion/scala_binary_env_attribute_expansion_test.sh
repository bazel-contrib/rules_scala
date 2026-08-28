#!/usr/bin/env bash
#
# Verifies that `scala_binary`'s `env` attribute is expanded correctly:
# $(rootpath ...) labels and toolchain-provided vars resolve, while
# $(BINDIR)/$UNKNOWN (not supported by this expansion) are left untouched.
# See: scala/private/phases/phase_expand_environment.bzl
#
# Bazel has no native "run bazel and diff its output" rule, and this needs an
# exact multi-line diff against output containing a value (BINDIR) this test
# itself must compute, so it can't reuse expect_build_failure.bzl's macros.
#
# Usage: scala_binary_env_attribute_expansion_test.sh <target> <expected-file>

set -euo pipefail

# Captured before nested_bazel_setup `cd`s into the workspace, so the
# runfiles-relative expected-file path below still resolves.
orig_pwd="${PWD}"

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

target="${1:?Usage: scala_binary_env_attribute_expansion_test.sh <target> <expected-file>}"
expected_template="${2:?Usage: scala_binary_env_attribute_expansion_test.sh <target> <expected-file>}"

# Resolves the expected-file path, tolerating an absolute path, a path
# relative to the original working directory (before nested_bazel_setup's
# `cd`), or one relative to the test's runfiles root.
for candidate in \
  "${expected_template}" \
  "${orig_pwd}/${expected_template}" \
  "${TEST_SRCDIR:-}/${TEST_WORKSPACE:-}/${expected_template}"; do
  if [[ -f "${candidate}" ]]; then
    expected_template="${candidate}"
    break
  fi
done

nested_bazel_setup "rules_scala_env_attribute_expansion_output_base"

bindir="$(nested_bazel_run info bazel-bin)"
bindir="bazel-out/${bindir#*/bazel-out/}"

# Only the binary's own stdout is diffed against the expected output; the
# nested `bazel run`'s build progress goes to stderr and is left alone.
actual="$(nested_bazel_run run "${target}")"

expected_file="$(mktemp)"
trap 'rm -f "${expected_file}"' EXIT
sed "s|{{BINDIR}}|${bindir}|" "${expected_template}" > "${expected_file}"

diff -u --strip-trailing-cr "${expected_file}" <(printf '%s\n' "${actual}")
