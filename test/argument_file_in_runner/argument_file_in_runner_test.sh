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

if ! output="$(nested_bazel_run build --extra_toolchains=//test/toolchains:use_argument_file_in_runner "${target}" 2>&1)"; then
  echo "Expected build of ${target} under use_argument_file_in_runner to succeed, but it failed." >&2
  echo "${output}" >&2
  exit 1
fi
if [[ ! "$(< "${runner_path}")" =~ \"argsfile\"\ ==\ \"argsfile\" ]]; then
  echo "Expected the runner script to use the argument file, but it did not." >&2
  exit 1
fi

if ! output="$(nested_bazel_run build "${target}" 2>&1)"; then
  echo "Expected build of ${target} to succeed, but it failed." >&2
  echo "${output}" >&2
  exit 1
fi
if [[ ! "$(< "${runner_path}")" =~ \"manifest\"\ ==\ \"argsfile\" ]]; then
  echo "Expected the runner script to use the classpath jar, but it did not." >&2
  exit 1
fi
