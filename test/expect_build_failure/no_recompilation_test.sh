#!/usr/bin/env bash
#
# Regression test for the ijar/interface-jar correctness contract: a change to
# a target's internal (non-signature) source code must not force a rebuild of
# its consumer, since the consumer only ever compiles against the target's
# interface jar.
#
# Builds <target> once against a nested output base, then replaces the
# quoted string literal "<search-word>" with "<replace-word>" in
# <changed-file> in the real source tree, and builds <target> again with
# --subcommands. Fails if <not-expected> appears in the second build's
# output (meaning the consumer action ran, i.e. it recompiled).
#
# <search-word>/<replace-word> (not a raw sed expression) so the args stay
# free of shell metacharacters like ( and " -- Bazel's test wrapper on
# Windows re-parses argv through another shell, which mangles those.
#
# Usage:
#   no_recompilation_test.sh --target=<label-or-pattern> --changed-file=<path>
#     --search-word=<word> --replace-word=<word> --not-expected=<substring>
#     [--extra-toolchain=<label>]

set -euo pipefail

target=""
changed_file=""
search_word=""
replace_word=""
not_expected=""
extra_toolchain=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target=*) target="${1#*=}"; shift ;;
    --changed-file=*) changed_file="${1#*=}"; shift ;;
    --search-word=*) search_word="${1#*=}"; shift ;;
    --replace-word=*) replace_word="${1#*=}"; shift ;;
    --not-expected=*) not_expected="${1#*=}"; shift ;;
    --extra-toolchain=*) extra_toolchain="${1#*=}"; shift ;;
    *) echo "Unexpected argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "${target}" || -z "${changed_file}" || -z "${search_word}" || -z "${replace_word}" || -z "${not_expected}" ]]; then
  echo "Usage: no_recompilation_test.sh --target=<label-or-pattern> --changed-file=<path> --search-word=<word> --replace-word=<word> --not-expected=<substring> [--extra-toolchain=<label>]" >&2
  exit 1
fi

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"
nested_bazel_setup "rules_scala_no_recompilation_output_base"

toolchain_args=()
if [[ -n "${extra_toolchain}" ]]; then
  toolchain_args+=("--extra_toolchains=${extra_toolchain}")
fi

changed_file_path="${NESTED_BAZEL_WORKSPACE}/${changed_file}"
backup_path="${changed_file_path}.bak"
restore() {
  if [[ -f "${backup_path}" ]]; then
    mv "${backup_path}" "${changed_file_path}"
  fi
}
trap restore EXIT

if ! initial_output="$(nested_bazel_run build ${toolchain_args[@]+"${toolchain_args[@]}"} "${target}" 2>&1)"; then
  echo "Expected initial build of ${target} to succeed." >&2
  echo "${initial_output}" >&2
  exit 1
fi

sed -i.bak "s/(\"${search_word}\")/(\"${replace_word}\")/" "${changed_file_path}"

# A sed expression that matches nothing still exits 0, which would silently
# turn the assertion below into a vacuous pass (no recompilation, because
# nothing was actually changed).
if cmp -s "${backup_path}" "${changed_file_path}"; then
  echo "'${search_word}' -> '${replace_word}' did not change ${changed_file}." >&2
  exit 1
fi

if ! second_output="$(nested_bazel_run build ${toolchain_args[@]+"${toolchain_args[@]}"} "${target}" --subcommands 2>&1)"; then
  echo "Expected second build of ${target} to succeed after changing ${changed_file}." >&2
  echo "${second_output}" >&2
  exit 1
fi

if grep -qF -- "${not_expected}" <<<"${second_output}"; then
  echo "Found '${not_expected}' in the second build's output: an internal-only change to ${changed_file} triggered a recompilation it should not have." >&2
  exit 1
fi
