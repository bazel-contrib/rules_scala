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

if ! build_output="$(nested_bazel_run build --repo_env=SCALA_VERSION=0.0.0 @rules_scala_config//:all 2>&1)"; then
  echo "Build of @rules_scala_config//:all failed:" >&2
  echo "${build_output}" >&2
  exit 1
fi

output_base="$(nested_bazel_run info output_base)"
# The repo's canonical name is prefixed under bzlmod (e.g.
# `+scala_config+rules_scala_config`), so match the suffix. The shared output base
# can retain a stale `*rules_scala_config` dir from an earlier bzlmod hash, so the
# glob may match more than one config.bzl -- check them all rather than just the
# first.
config_bzl=("${output_base}"/external/*rules_scala_config/config.bzl)
if [[ ! -f "${config_bzl[0]}" ]]; then
  echo "Could not find a generated rules_scala_config config.bzl under" \
    "${output_base}/external." >&2
  exit 1
fi

if ! grep --quiet --fixed-strings "SCALA_MAJOR_VERSION='0.0'" "${config_bzl[@]}"; then
  echo "Expected SCALA_MAJOR_VERSION='0.0' in one of ${config_bzl[*]} under" \
    "SCALA_VERSION=0.0.0, but it was absent. config.bzl contents:" >&2
  cat "${config_bzl[@]}" >&2
  exit 1
fi
