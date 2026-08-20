#!/usr/bin/env bash
#
# Asserts the scalac Javac action's inputs carry the scala-library matching the
# SCALA_VERSION selected via `--repo_env`. Parameterised so one script backs both
# the 2.12 and 2.13 targets (see this package's BUILD).
#
# Args:
#   $1  SCALA_VERSION to build under (e.g. 2.12.21).
#   $2  the scala-library substring expected on the action's inputs (e.g.
#       scala-library-2.12).
#
# The signal is a nested `bazel aquery`'s stdout, not a build/test *outcome*, so
# this is a bespoke sh_test rather than an expect_build_failure.bzl macro. The
# nested `bazel` (and the rationale for it) lives in the shared nested_bazel.sh
# helper this script sources.

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

scala_version="${1:?usage: scalac_javac_scala_library_test.sh <scala_version> <expected_library>}"
expected_library="${2:?usage: scalac_javac_scala_library_test.sh <scala_version> <expected_library>}"

nested_bazel_setup "rules_scala_scala_config_output_base"

if ! output="$(nested_bazel_run aquery \
  'mnemonic("Javac", //src/java/io/bazel/rulesscala/scalac:scalac)' \
  "--repo_env=SCALA_VERSION=${scala_version}" 2>&1)"; then
  echo "aquery under SCALA_VERSION=${scala_version} failed:" >&2
  echo "${output}" >&2
  exit 1
fi

if ! grep --quiet --fixed-strings "${expected_library}" <<<"${output}"; then
  echo "Expected the scalac Javac action to use '${expected_library}' under" \
    "SCALA_VERSION=${scala_version}, but it did not. aquery output:" >&2
  echo "${output}" >&2
  exit 1
fi
