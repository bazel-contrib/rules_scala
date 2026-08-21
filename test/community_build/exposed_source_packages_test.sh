#!/usr/bin/env bash
#
# Fails loudly if a BUILD/BUILD.bazel file exists under scala/, src/, or
# third_party/ whose package isn't in the EXPOSED_SOURCE_PACKAGES list passed
# in as args (see exposed_source_packages.bzl). Prunes embedded child
# workspaces (a WORKSPACE/WORKSPACE.bazel file marks one) first, the same way
# bazel-contrib/rules_bazel_integration_test's find_child_workspace_packages.sh
# does -- Bazel itself walls those off from this module's package tree, so
# they can never be part of what a downstream consumer's build reaches either.

set -euo pipefail

srcdir="${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}"
workspace="${TEST_WORKSPACE:-_main}"
# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${srcdir}/${workspace}/test/expect_build_failure/nested_bazel.sh"

root="$(_nested_bazel_find_workspace)"

child_workspace_dirs="$(cd "${root}" && find scala src third_party \( -name WORKSPACE -o -name WORKSPACE.bazel \) -exec dirname {} \;)"

actual="$(
  cd "${root}"
  find scala src third_party \( -name BUILD -o -name BUILD.bazel \) -exec dirname {} \; | while IFS= read -r pkg; do
    skip=0
    while IFS= read -r child; do
      [[ -z "${child}" ]] && continue
      if [[ "${pkg}" == "${child}" || "${pkg}" == "${child}"/* ]]; then
        skip=1
        break
      fi
    done <<< "${child_workspace_dirs}"
    [[ "${skip}" -eq 0 ]] && printf '%s\n' "${pkg}"
  done | sort
)"
expected="$(printf '%s\n' "$@" | sort)"

if [[ "${actual}" == "${expected}" ]]; then
  echo "OK: exposed_source_packages.bzl matches the checkout."
  exit 0
fi

echo "exposed_source_packages.bzl (EXPOSED_SOURCE_PACKAGES) is out of date." >&2
echo "" >&2
echo "On disk but not in the list:" >&2
comm -23 <(printf '%s\n' "${actual}") <(printf '%s\n' "${expected}") >&2
echo "" >&2
echo "In the list but not on disk:" >&2
comm -13 <(printf '%s\n' "${actual}") <(printf '%s\n' "${expected}") >&2
exit 1
