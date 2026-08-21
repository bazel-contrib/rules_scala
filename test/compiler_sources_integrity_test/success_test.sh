#!/usr/bin/env bash
#
# Builds //... in the nested test/compiler_sources_integrity module and
# asserts the build succeeds without Bazel's "canonical reproducible form"
# warning (emitted for a downloaded jar missing integrity data).
#
# test/compiler_sources_integrity is a separate Bazel module (its own
# MODULE.bazel/WORKSPACE, local_path_override'd onto this checkout) excluded
# from this repo's own package tree by .bazelignore (see
# https://github.com/bazelbuild/bazel/issues/22208), so a label inside it
# cannot be passed to the expect_build_failure.bzl macros, which build a
# label in this same workspace. This drives a nested `bazel` directly instead.
# The nested `bazel` (and the rationale for it) lives in the shared
# nested_bazel.sh helper this script sources.
#
# Usage: success_test.sh [--scala-version VERSION]

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

scala_version=""
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --scala-version)
      scala_version="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

nested_bazel_setup "rules_scala_compiler_sources_integrity_output_base"
cd test/compiler_sources_integrity

# Without this, a build already served from the nested output base's on-disk
# cache would skip recompiling and reprint no warning, regardless of whether
# one would otherwise be emitted.
nested_bazel_run clean >/dev/null 2>&1

build_args=()
if [[ -n "${scala_version}" ]]; then
  build_args+=("--repo_env=SCALA_VERSION=${scala_version}")
fi

if ! output="$(nested_bazel_run build ${build_args[@]+"${build_args[@]}"} //... 2>&1)"; then
  echo "${output}" >&2
  echo "build failed" >&2
  exit 1
fi

crf_warning="canonical reproducible form"
if grep --quiet --fixed-strings "${crf_warning}" <<<"${output}"; then
  echo "${output}" >&2
  echo "build output contained \"${crf_warning}\" warning" >&2
  exit 1
fi
