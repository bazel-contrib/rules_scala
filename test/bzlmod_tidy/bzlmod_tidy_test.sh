#!/usr/bin/env bash
# Runs `bazel mod tidy` against one repo MODULE.bazel file and checks it
# leaves the file unchanged. See bzlmod_tidy.bzl for why this mutates and
# restores the checkout on disk, and why it always re-runs.
#
# Usage: bzlmod_tidy_test.sh <module-dir>
# <module-dir> is a repo-relative directory ("." for the root) containing a
# MODULE.bazel file.

set -euo pipefail

if [[ "$#" -ne 1 ]]; then
  echo "Usage: bzlmod_tidy_test.sh <module-dir>" >&2
  exit 2
fi
module_dir="$1"

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"
nested_bazel_setup "rules_scala_bzlmod_tidy_output_base"

module_path="${NESTED_BAZEL_WORKSPACE}/${module_dir}/MODULE.bazel"
lock_path="${module_path}.lock"
tmpdir="${TEST_TMPDIR:?TEST_TMPDIR must be set}"
backup="${tmpdir}/MODULE.bazel.orig"
lock_backup="${tmpdir}/MODULE.bazel.lock.orig"

cp "${module_path}" "${backup}"
# `bazel mod tidy` also rewrites the lock file's computed digests in place
# when present, so it needs the same restore-on-exit treatment as
# MODULE.bazel itself. had_lock records whether one existed beforehand: on
# exit, a pre-existing lock file gets its original content back, while one
# tidy creates fresh gets deleted.
had_lock=0
if [[ -f "${lock_path}" ]]; then
  had_lock=1
  cp "${lock_path}" "${lock_backup}"
fi

on_exit() {
  local status=$?
  # Mirrors nested_bazel_setup's own EXIT trap, which this one replaces:
  # print its scrubbed-HOME hint on failure before restoring the checkout.
  if [[ "${status}" -ne 0 ]]; then
    _nested_bazel_home_hint
  fi
  cp "${backup}" "${module_path}"
  if [[ "${had_lock}" -eq 1 ]]; then
    cp "${lock_backup}" "${lock_path}"
  else
    rm -f "${lock_path}"
  fi
}
trap on_exit EXIT

cd "${NESTED_BAZEL_WORKSPACE}/${module_dir}"
nested_bazel_run mod tidy

if ! diff -u "${backup}" MODULE.bazel; then
  echo "ERROR: \`bazel mod tidy\` changed ${module_dir}/MODULE.bazel (diff above)." >&2
  exit 1
fi
