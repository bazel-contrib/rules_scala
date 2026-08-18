#!/usr/bin/env bash
#
# Verifies the scalac worker's compile classpath (as seen by `bazel aquery`)
# includes the scala-library jar matching the given Scala version.
#
# Usage: classpath_contains_scala_library_test.sh <scala-version> <expected-substring>

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

scala_version="${1:?Usage: $0 <scala-version> <expected-substring>}"
expected="${2:?Usage: $0 <scala-version> <expected-substring>}"

nested_bazel_setup "rules_scala_scala_config_output_base"

classpath="$(nested_bazel_run aquery \
  'mnemonic("Javac", //src/java/io/bazel/rulesscala/scalac:scalac)' \
  --repo_env="SCALA_VERSION=${scala_version}")"

if ! grep -q "${expected}" <<<"${classpath}"; then
  echo "Expected the scalac worker's classpath (Scala ${scala_version}) to contain \"${expected}\", but it did not:" >&2
  echo "${classpath}" >&2
  exit 1
fi
