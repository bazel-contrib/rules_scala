#!/usr/bin/env bash
#
# Asserts that a repository environment setting is reflected in the generated
# config.bzl, or that an invalid setting is rejected with a useful error.
#
# The signal is a generated external-repo file, not a build/test *outcome*, so
# this is a bespoke sh_test rather than an expect_build_failure.bzl macro. The
# nested `bazel` (and the rationale for it) lives in the shared nested_bazel.sh
# helper this script sources.

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

nested_bazel_setup "rules_scala_scala_config_output_base"

repo_env_flag="$1"
# Encode literal single quotes in BUILD args so both Unix and Windows runners
# pass the same value to the script.
quote="'"
expected="${2//__QUOTE__/${quote}}"
if [[ "${3:-}" == "expect-failure" ]]; then
  if build_output="$(nested_bazel_run build "${repo_env_flag}" @rules_scala_config//:all 2>&1)"; then
    echo "Expected @rules_scala_config to reject ${repo_env_flag}, but it built successfully." >&2
    exit 1
  fi
  if ! grep --quiet --fixed-strings "${expected}" <<<"${build_output}"; then
    echo "Expected error '${expected}' under ${repo_env_flag}, but got:" >&2
    echo "${build_output}" >&2
    exit 1
  fi
  exit 0
fi

if ! build_output="$(nested_bazel_run build "${repo_env_flag}" @rules_scala_config//:all 2>&1)"; then
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

if ! grep --quiet --fixed-strings "${expected}" "${config_bzl[@]}"; then
  echo "Expected '${expected}' in one of ${config_bzl[*]} under" \
    "${repo_env_flag}, but it was absent. config.bzl contents:" >&2
  cat "${config_bzl[@]}" >&2
  exit 1
fi
