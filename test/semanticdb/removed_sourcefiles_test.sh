#!/usr/bin/env bash
#
# Regression test: building lib_with_tempsrc must succeed both right after a
# new source file is added to it and right after that file is removed again
# (Windows previously failed the second build with an "access denied" on the
# removed file).
#
# Usage:
#   removed_sourcefiles_test.sh

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

nested_bazel_setup "rules_scala_semanticdb_output_base"

rule_label="//test/semanticdb:lib_with_tempsrc"
toolchain_arg="--extra_toolchains=//test/semanticdb:semanticdb_nobundle_toolchain"
newfile_dir="${NESTED_BAZEL_WORKSPACE}/test/semanticdb/tempsrc"
newfile_path="${newfile_dir}/D.scala"

# tempsrc is gitignored (it exists only for this test), so cleanup is a plain
# rm rather than a git checkout. Removes only the file this test created,
# not the whole directory, in case a developer has other scratch files there.
cleanup() {
  rm -f "${newfile_path}"
  rmdir "${newfile_dir}" 2>/dev/null || true
}
trap cleanup EXIT

mkdir -p "${newfile_dir}"
echo "class D{ val a = 1; }" > "${newfile_path}"

# Query Bazel's own dependency graph, not just the filesystem: this catches a
# regression in lib_with_tempsrc's glob pattern itself, which a plain
# `[[ -f ]]` check on the file we just wrote would not.
query_result1="$(nested_bazel_run query "labels(srcs, ${rule_label})" 2>&1)"
if [[ "${query_result1}" != *"D.scala"* ]]; then
  echo "D.scala was not properly added as src for target ${rule_label}" >&2
  echo "${query_result1}" >&2
  exit 1
fi

if ! build_output="$(nested_bazel_run build "${toolchain_arg}" "${rule_label}" 2>&1)"; then
  echo "Expected build of ${rule_label} to succeed with D.scala present." >&2
  echo "${build_output}" >&2
  exit 1
fi

rm "${newfile_path}"

query_result2="$(nested_bazel_run query "labels(srcs, ${rule_label})" 2>&1)"
if [[ "${query_result2}" == *"D.scala"* ]]; then
  echo "D.scala was not properly removed as src for target ${rule_label}" >&2
  echo "${query_result2}" >&2
  exit 1
fi

if ! build_output="$(nested_bazel_run build "${toolchain_arg}" "${rule_label}" 2>&1)"; then
  echo "Expected build of ${rule_label} to succeed after D.scala was removed." >&2
  echo "${build_output}" >&2
  exit 1
fi
