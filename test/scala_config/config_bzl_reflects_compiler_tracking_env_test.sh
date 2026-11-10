#!/usr/bin/env bash
#
# Check that the Bzlmod configuration extension accepts a string supplied by
# --repo_env and writes a boolean to the generated Scala configuration.

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

nested_bazel_setup "rules_scala_compiler_tracking_env_output_base"

output_base="$(nested_bazel_run info output_base)"

for value in True False; do
  if ! build_output="$(nested_bazel_run build \
    "--repo_env=ENABLE_COMPILER_DEPENDENCY_TRACKING=${value}" \
    @rules_scala_config//:all 2>&1)"; then
    echo "Building @rules_scala_config with compiler tracking ${value} failed:" >&2
    echo "${build_output}" >&2
    exit 1
  fi

  config_bzl=("${output_base}"/external/*rules_scala_config/config.bzl)
  if [[ ! -f "${config_bzl[0]}" ]]; then
    echo "Could not find the generated Scala config under ${output_base}/external." >&2
    exit 1
  fi
  if ! grep --quiet --fixed-strings \
    "ENABLE_COMPILER_DEPENDENCY_TRACKING=${value}" "${config_bzl[@]}"; then
    echo "Expected compiler tracking ${value} in ${config_bzl[*]}:" >&2
    cat "${config_bzl[@]}" >&2
    exit 1
  fi
done
