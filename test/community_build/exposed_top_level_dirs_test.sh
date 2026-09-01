#!/usr/bin/env bash
#
# Fails if a top-level entry (file or directory) exists on disk that
# source_fingerprint.bzl's _PUBLIC_DIRS/_PUBLIC_ROOT_FILES, _INTERNAL_ENTRIES,
# and _LOCAL_ONLY_FILES don't together account for -- so a new one can't
# silently miss the fingerprint's scope. `bazel-*` (this checkout's own
# convenience symlinks into Bazel's output_base, whose exact name varies by
# checkout) is skipped by pattern.
#
# Usage: exposed_top_level_dirs_test.sh <public-entry>... -- <internal-entry>...

set -euo pipefail

srcdir="${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}"
workspace="${TEST_WORKSPACE:-_main}"
# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${srcdir}/${workspace}/test/expect_build_failure/nested_bazel.sh"

root="$(_nested_bazel_find_workspace)"

known=()
while [[ "$#" -gt 0 && "$1" != "--" ]]; do
  known+=("$1")
  shift
done
shift # drop --
known+=("$@")

actual="$(cd "${root}" && find . -mindepth 1 -maxdepth 1 -exec basename {} \; | sort)"

unknown=()
while IFS= read -r entry; do
  [[ "${entry}" == bazel-* ]] && continue
  found=0
  for k in "${known[@]}"; do
    [[ "${entry}" == "${k}" ]] && found=1 && break
  done
  [[ "${found}" -eq 0 ]] && unknown+=("${entry}")
done <<< "${actual}"

if [[ "${#unknown[@]}" -eq 0 ]]; then
  echo "OK: every top-level entry is accounted for."
  exit 0
fi

echo "New top-level entry not in source_fingerprint.bzl's _PUBLIC_DIRS," >&2
echo "_PUBLIC_ROOT_FILES, _INTERNAL_ENTRIES, or _LOCAL_ONLY_FILES -- classify" >&2
echo "it and add it there:" >&2
printf '  %s\n' "${unknown[@]}" >&2
exit 1
