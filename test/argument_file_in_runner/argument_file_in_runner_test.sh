#!/usr/bin/env bash
#
# Asserts that scala_binary's generated runner script switches its classpath
# strategy based on the use_argument_file_in_runner toolchain setting: an
# argsfile under the opt-in toolchain, and (for a classpath this large) a
# manifest jar under the default toolchain.
#
# The signal is the runner script's own content, not a build/test outcome, so
# this uses a custom sh_test instead of one of expect_build_failure.bzl's
# macros. The nested `bazel build` (and the rationale for it) lives in the
# shared nested_bazel.sh helper this script sources.

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

nested_bazel_setup "rules_scala_argument_file_in_runner_output_base"

target="//test/src/main/scala/scalarules/test/large_classpath:largeClasspath"
runner_relpath="test/src/main/scala/scalarules/test/large_classpath/largeClasspath"
bazel_bin="$(nested_bazel_run info bazel-bin)"
runner_path="${bazel_bin}/${runner_relpath}"

# java_stub_template/file/file.txt substitutes the toolchain-picked mode into a
# literal `if [ "<mode>" == "argsfile" ]` line (see
# phase_write_executable.bzl's test_runner_classpath_mode), so grepping for
# that line in the built runner script reveals which mode won.
assert_runner_mode() {
  local mode="$1"
  if [[ ! "$(< "${runner_path}")" == *"if [ \"${mode}\" == \"argsfile\" ]"* ]]; then
    echo "Expected the runner script to pick classpath mode '${mode}', but it did not." >&2
    exit 1
  fi
}

if ! output="$(nested_bazel_run build --extra_toolchains=//test/toolchains:use_argument_file_in_runner "${target}" 2>&1)"; then
  echo "Expected build of ${target} under use_argument_file_in_runner to succeed, but it failed." >&2
  echo "${output}" >&2
  exit 1
fi
assert_runner_mode "argsfile"

if ! output="$(nested_bazel_run build "${target}" 2>&1)"; then
  echo "Expected build of ${target} to succeed, but it failed." >&2
  echo "${output}" >&2
  exit 1
fi
assert_runner_mode "manifest"
