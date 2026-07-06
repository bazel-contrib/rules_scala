#!/usr/bin/env bash
#
# Regression test for https://github.com/bazel-contrib/rules_scala/issues/1819:
# `scala_macro_library` must NOT emit an ijar, because ijar strips the macro
# implementations that consumers need on the compile classpath.
#
# Verifies that building <target> under each given Scala version succeeds but
# does not produce the ijar at <ijar-workspace-relative-path> (relative to
# bazel-bin).
#
# The nested `bazel build` (and the rationale for it) lives in the shared
# nested_bazel.sh helper this script sources.
#
# Usage:
#   expect_no_ijar.sh <target> <ijar-path-relative-to-bazel-bin> <scala-version>...

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

target="${1:-}"
ijar_relpath="${2:-}"
shift 2 2>/dev/null || true
scala_versions=("$@")

if [[ -z "${target}" || -z "${ijar_relpath}" || "${#scala_versions[@]}" -eq 0 ]]; then
  echo "Usage: expect_no_ijar.sh <target> <ijar-path> <scala-version>..." >&2
  exit 2
fi

nested_bazel_setup "rules_scala_expect_no_ijar_output_base"

for scala_version in "${scala_versions[@]}"; do
  repo_env="--repo_env=SCALA_VERSION=${scala_version}"

  if ! build_output="$(nested_bazel_run build "${repo_env}" "${target}" 2>&1)"; then
    echo "Expected build of ${target} (Scala ${scala_version}) to succeed, but it failed." >&2
    echo "${build_output}" >&2
    exit 1
  fi

  bazel_bin="$(nested_bazel_run info "${repo_env}" bazel-bin 2>/dev/null)"
  ijar_path="${bazel_bin}/${ijar_relpath}"

  if [[ -f "${ijar_path}" ]]; then
    echo "scala_macro_library should not produce an ijar on Scala ${scala_version}, but found:" >&2
    echo "  ${ijar_path}" >&2
    exit 1
  fi
done
