#!/usr/bin/env bash
#
# Asserts the @rules_scala_config repo is regenerated from SCALA_VERSION: building
# it under a fake SCALA_VERSION=0.0.0 must write that version into the generated
# config.bzl.
#
# The signal is a generated external-repo file, not a build/test *outcome*, so
# this is a bespoke sh_test rather than an expect_build_failure.bzl macro. The
# nested `bazel` (and the rationale for it) lives in the shared nested_bazel.sh
# helper this script sources.

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

nested_bazel_setup "rules_scala_scala_config_output_base"

nested_bazel_run build --repo_env=SCALA_VERSION=0.0.0 @rules_scala_config//:all >/dev/null 2>&1

output_base="$(nested_bazel_run info output_base)"
# The repo's canonical name is prefixed under bzlmod (e.g.
# `+scala_config+rules_scala_config`), so match the suffix.
config_bzl=("${output_base}"/external/*rules_scala_config/config.bzl)
if [[ ! -f "${config_bzl[0]}" ]]; then
  echo "Could not find a generated rules_scala_config config.bzl under" \
    "${output_base}/external." >&2
  exit 1
fi

if ! grep --quiet --fixed-strings "SCALA_MAJOR_VERSION='0.0'" "${config_bzl[0]}"; then
  echo "Expected SCALA_MAJOR_VERSION='0.0' in ${config_bzl[0]} under" \
    "SCALA_VERSION=0.0.0, but it was absent. config.bzl:" >&2
  cat "${config_bzl[0]}" >&2
  exit 1
fi
