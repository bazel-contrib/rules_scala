#!/usr/bin/env bash
#
# Regression test: after a dependency's class disappears, a rebuild of a
# target that references it must fail, not silently reuse a stale cached
# result for the target that still referenced the removed class.
#
# Builds <target> once against a nested output base, then overwrites
# <class-provider-relpath> in the real source tree with the contents of
# <replacement-relpath> (which no longer defines the class <target> depends
# on) and builds <target> again against the same output base. The second
# build must fail.
#
# Usage:
#   disappearing_class_test.sh <target> <class-provider-relpath> <replacement-relpath>

set -euo pipefail

# Captured before nested_bazel_setup `cd`s into the workspace, so a
# runfiles-relative replacement path still resolves.
orig_pwd="${PWD}"

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

target="${1:-}"
class_provider_relpath="${2:-}"
replacement_relpath="${3:-}"

if [[ -z "${target}" || -z "${class_provider_relpath}" || -z "${replacement_relpath}" ]]; then
  echo "Usage: disappearing_class_test.sh <target> <class-provider-relpath> <replacement-relpath>" >&2
  exit 2
fi

# Same tolerant resolution expect_build_failure.sh uses for message files: the
# replacement lives in runfiles, read before nested_bazel_setup's `cd`.
_resolve_runfile() {
  local file="$1"
  local candidate
  for candidate in \
    "${file}" \
    "${orig_pwd}/${file}" \
    "${TEST_SRCDIR:-}/${TEST_WORKSPACE:-}/${file}"; do
    if [[ -f "${candidate}" ]]; then
      printf '%s' "${candidate}"
      return
    fi
  done
  printf '%s' "${file}"
}
replacement_path="$(_resolve_runfile "${replacement_relpath}")"

nested_bazel_setup "rules_scala_disappearing_class_output_base"

class_provider_path="${NESTED_BAZEL_WORKSPACE}/${class_provider_relpath}"
backup_path="$(mktemp)"
cp "${class_provider_path}" "${backup_path}"
restore() {
  cp "${backup_path}" "${class_provider_path}"
  rm -f "${backup_path}"
}
trap restore EXIT

if ! nested_bazel_run build "${target}" >/dev/null 2>&1; then
  echo "Expected initial build of ${target} to succeed." >&2
  exit 1
fi

cp "${replacement_path}" "${class_provider_path}"

if nested_bazel_run build "${target}" >/dev/null 2>&1; then
  echo "Expected build of ${target} to fail after ${class_provider_relpath}'s class disappeared, but it succeeded (stale cache)." >&2
  exit 1
fi
