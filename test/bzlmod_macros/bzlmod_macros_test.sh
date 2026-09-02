#!/usr/bin/env bash
# Creates standalone bzlmod consumer modules and checks the values produced by
# scala/private/macros/bzlmod.bzl's root_module_tags/single_tag_values/
# repeated_tag_values logic. Config comes from the calling BUILD target's
# args, built by bzlmod_macros.bzl's bzlmod_macro_test/bzlmod_fake_root_module_test
# macros.
#
# Usage:
#   bzlmod_macros_test.sh --target=<label> [--tag=<MODULE.bazel line>]...
#     (--expect=<regex> | --expect-fail=<regex>)
#   bzlmod_macros_test.sh --fake-root-module-tags

set -euo pipefail

target=""
tag_lines=()
expect_regex=""
expect_fail_regex=""
fake_root=0

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --target=*)
      target="${1#*=}"
      shift
      ;;
    --tag=*)
      tag_lines+=("${1#*=}")
      shift
      ;;
    --expect=*)
      expect_regex="${1#*=}"
      shift
      ;;
    --expect-fail=*)
      expect_fail_regex="${1#*=}"
      shift
      ;;
    --fake-root-module-tags)
      fake_root=1
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [[ "${fake_root}" -eq 0 ]]; then
  if [[ -z "${target}" ]]; then
    echo "--target is required unless --fake-root-module-tags is passed" >&2
    exit 2
  fi
  if [[ -n "${expect_regex}" && -n "${expect_fail_regex}" ]] || [[ -z "${expect_regex}" && -z "${expect_fail_regex}" ]]; then
    echo "Pass exactly one of --expect or --expect-fail" >&2
    exit 2
  fi
fi

# bzlmod's module-extension APIs used here require Bazel 7.1+ (this repo's own
# MODULE.bazel declares the same floor via bazel_compatibility).
if [[ "$(bazel --version)" =~ ^bazel\ 6\. ]]; then
  echo "Skipping bzlmod macro test: requires Bazel 7.1 or newer."
  exit 0
fi

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"
nested_bazel_setup "rules_scala_bzlmod_macros_output_base"

fixture_dir="${NESTED_BAZEL_WORKSPACE}/test/bzlmod_macros"
workspace_base="${TEST_TMPDIR:?TEST_TMPDIR must be set}/workspace"
root_module_dir="${workspace_base}/root_module"
test_module_dir="${workspace_base}/test_module"

rm -rf "${root_module_dir}" "${test_module_dir}"
mkdir -p "${root_module_dir}"

convert_msys2_path() {
  local path="$1"
  if command -v cygpath >/dev/null; then
    path="$(cygpath -m "${path}")"
  fi
  printf '%s' "${path}"
}

rules_scala_dir="$(convert_msys2_path "${NESTED_BAZEL_WORKSPACE}")"
latest_deps_dir="$(convert_msys2_path "${NESTED_BAZEL_WORKSPACE}/deps/latest")"

# write_bazel_config <module_dir> copies the repo's .bazelversion and a
# lockfile_mode=update copy of its .bazelrc into a scratch module directory,
# outside the repo, where bazelisk would otherwise fall back to its own
# default Bazel version instead of the one this repo pins.
write_bazel_config() {
  local module_dir="$1"
  cp "${NESTED_BAZEL_WORKSPACE}/.bazelversion" "${module_dir}/"
  sed -e 's/--lockfile_mode=error/--lockfile_mode=update/' \
    "${NESTED_BAZEL_WORKSPACE}/.bazelrc" >"${module_dir}/.bazelrc"
}

# setup_test_module <module_dir> [MODULE.bazel tag line]...
setup_test_module() {
  local module_dir="$1"
  shift
  mkdir -p "${module_dir}"
  write_bazel_config "${module_dir}"
  cp "${fixture_dir}/bzlmod_test_ext.bzl" "${module_dir}/"
  cp "${fixture_dir}/BUILD.bzlmod_test" "${module_dir}/BUILD"
  sed \
    -e "s%\${rules_scala_dir}%${rules_scala_dir}%" \
    -e "s%\${latest_deps_dir}%${latest_deps_dir}%" \
    "${fixture_dir}/MODULE.bzlmod_test" >"${module_dir}/MODULE.bazel"
  if [[ "$#" -gt 0 ]]; then
    printf '%s\n' "$@" >>"${module_dir}/MODULE.bazel"
  fi
}

assert_matches() {
  local expected="$1"
  local actual="$2"
  if [[ ! "${actual}" =~ ${expected} ]]; then
    printf 'Expected output to match regex: %s\nActual output:\n%s\n' \
      "${expected}" "${actual}" >&2
    exit 1
  fi
}

# run_target <bazel target label> runs it via a nested `bazel run
# --enable_bzlmod`, from within the current directory's module, and prints its
# combined stdout/stderr. Its exit status is the nested command's.
run_target() {
  nested_bazel_run run --enable_bzlmod "$1" 2>&1
}

if [[ "${fake_root}" -eq 1 ]]; then
  setup_test_module "${test_module_dir}"
  test_module_path="$(convert_msys2_path "${test_module_dir}")"
  write_bazel_config "${root_module_dir}"
  sed \
    -e "s%\${rules_scala_dir}%${rules_scala_dir}%" \
    -e "s%\${latest_deps_dir}%${latest_deps_dir}%" \
    -e "s%\${test_module_dir}%${test_module_path}%" \
    "${fixture_dir}/MODULE.bzlmod_test_root_module" \
    >"${root_module_dir}/MODULE.bazel"
  cd "${root_module_dir}"
  if ! output="$(run_target '@test_module//:print-single-test-tag-values')"; then
    echo "${output}" >&2
    echo "Nested bazel run failed." >&2
    exit 1
  fi
  assert_matches 'foo bar baz$' "${output}"
  exit 0
fi

setup_test_module "${root_module_dir}" "${tag_lines[@]+"${tag_lines[@]}"}"
cd "${root_module_dir}"

if [[ -n "${expect_fail_regex}" ]]; then
  if output="$(run_target "${target}")"; then
    echo "${output}" >&2
    echo "Nested bazel run should have failed but passed." >&2
    exit 1
  fi
  assert_matches "${expect_fail_regex}" "${output}"
else
  if ! output="$(run_target "${target}")"; then
    echo "${output}" >&2
    echo "Nested bazel run failed." >&2
    exit 1
  fi
  assert_matches "${expect_regex}" "${output}"
fi
