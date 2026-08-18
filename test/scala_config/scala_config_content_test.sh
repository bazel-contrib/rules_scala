#!/usr/bin/env bash
#
# Verifies @rules_scala_config generates a config.bzl reflecting the requested
# SCALA_VERSION.

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

nested_bazel_setup "rules_scala_scala_config_output_base"

if ! build_output="$(nested_bazel_run build --repo_env=SCALA_VERSION=0.0.0 @rules_scala_config//:all 2>&1)"; then
  echo "Expected build of @rules_scala_config//:all (SCALA_VERSION=0.0.0) to succeed, but it failed." >&2
  echo "${build_output}" >&2
  exit 1
fi

output_base="$(nested_bazel_run info output_base 2>/dev/null)"
config_file="$(ls "${output_base}"/external/*rules_scala_config/config.bzl)"

if ! grep -q "SCALA_MAJOR_VERSION='0.0'" "${config_file}"; then
  echo "Expected ${config_file} to declare SCALA_MAJOR_VERSION='0.0', but got:" >&2
  cat "${config_file}" >&2
  exit 1
fi
