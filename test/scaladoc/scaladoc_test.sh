#!/usr/bin/env bash
# Test scaladoc fixture in //test/scaladoc:scaladoc_* under 
# //test/toolchains:ast_plus_one_deps_unused_deps_warn.
#
# Usage:
#   scaladoc_test.sh --target=<label> [--expect-file=<file>]... [--reject-file=<file>]...
#
# Args:
#       --target=label                  : target label for bazel build/cquery
#       --expect-file=file              : filename(s) (not paths) that must exist after scaladoc run
#       --reject-file=file              : filename(s) that must NOT exist after scaladoc run

set -euo pipefail

TARGET=""
EXPECT_FILES=()
REJECT_FILES=()

while [[ $# -gt 0 ]]; do
    case "$1" in
           --target=*)
            TARGET="${1#*=}"
            shift
              ;;
          --expect-file=*)
            EXPECT_FILE="${1#*=}"
            EXPECT_FILES+=("${EXPECT_FILE}")
            shift
              ;;
         --reject-file=*)
            REJECT_FILE="${1#*=}"
            REJECT_FILES+=("${REJECT_FILE}")
            shift
              ;;
           *)
            echo "Unexpected argument: $1" >&2
            exit 1
              ;;
    esac
done

if [[ -z "${TARGET:-}" ]]; then
    echo "Usage: scaladoc_test.sh --target=label [--expect-file=file]... [--reject-file=file]..." >&2
    exit 1
fi

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"
nested_bazel_setup "rules_scala_scaladoc_test_output_base"

if ! BUILD_OUTPUT=$(nested_bazel_run build "${TARGET}" --extra_toolchains=//test/toolchains:ast_plus_one_deps_unused_deps_warn 2>&1); then
    echo "Build of ${TARGET} failed:" >&2
    echo "${BUILD_OUTPUT}" >&2
    exit 1
fi

# Resolve the real workspace-relative output path via bazel-bin, not cquery symlinks.
cquery_relpath=$(nested_bazel_run cquery "${TARGET}" --extra_toolchains=//test/toolchains:ast_plus_one_deps_unused_deps_warn --output=files)
bazel_bin=$(nested_bazel_run info --extra_toolchains=//test/toolchains:ast_plus_one_deps_unused_deps_warn bazel-bin)
SCALADOC_DIR="${bazel_bin}/${cquery_relpath#*/bin/}"

for f in "${EXPECT_FILES[@]:-}"; do
    if [[ ! -f "${SCALADOC_DIR}/${f}" ]]; then
        echo "Expected scaladoc file not found at ${SCALADOC_DIR}/${f}" >&2
        exit 1
    fi
done

for f in "${REJECT_FILES[@]:-}"; do
    if [[ -f "${SCALADOC_DIR}/${f}" ]]; then
        echo "Unexpected scaladoc file found at ${SCALADOC_DIR}/${f}" >&2
        exit 1
    fi
done

echo "Scaladoc test passed."
