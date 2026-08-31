#!/usr/bin/env bash
# Creates standalone bzlmod consumer modules and checks the values produced by
# scala/private/macros/bzlmod.bzl's root_module_tags/single_tag_values/
# repeated_tag_values logic.
#
# Usage: bzlmod_macros_test.sh --case=<case-name>
# See the `case` statement below for the full list of case names.

set -euo pipefail

case_name=""
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --case=*)
      case_name="${1#*=}"
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "${case_name}" ]]; then
  echo "Usage: bzlmod_macros_test.sh --case=<case-name>" >&2
  exit 2
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

# Matches the "at <path>/MODULE.bazel:<line>" location bazel appends to a
# module-extension tag error; broad enough to match any tmpdir path, since only
# the message text needs a precise match.
module_bazel_regex='[^ ]+MODULE.bazel'

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

target=""
tag_lines=()
expect_regex=""
expect_fail_regex=""

case "${case_name}" in
  single-tag-defaults)
    target='//:print-single-test-tag-values'
    expect_regex='foo bar baz$'
    ;;
  single-tag-regular-root-values)
    target='//:print-single-test-tag-values'
    tag_lines=('test_ext.single_test_tag(first = "quux", third = "plugh")')
    expect_regex='quux bar plugh$'
    ;;
  single-tag-dev-root-values)
    target='//:print-single-test-tag-values'
    tag_lines=('dev_test_ext.single_test_tag(first = "quux", third = "plugh")')
    expect_regex='quux bar plugh$'
    ;;
  single-tag-combines-regular-and-dev)
    target='//:print-single-test-tag-values'
    tag_lines=(
      'test_ext.single_test_tag(first = "quux", third = "plugh")'
      'dev_test_ext.single_test_tag(second = "xyzzy", third = "frobozz")'
    )
    expect_regex='quux xyzzy frobozz$'
    ;;
  single-tag-fails-if-more-than-two-tags)
    target='//:print-single-test-tag-values'
    tag_lines=(
      'test_ext.single_test_tag()'
      'dev_test_ext.single_test_tag()'
      'dev_test_ext.single_test_tag(second = "not", third = "happening")'
    )
    expect_fail_regex="expected one regular tag instance and/or one dev_dependency instance, got 3: 'single_test_tag' tag at ${module_bazel_regex}:"
    ;;
  single-tag-fails-if-dev-tag-before-regular)
    target='//:print-single-test-tag-values'
    tag_lines=(
      'dev_test_ext.single_test_tag()'
      'test_ext.single_test_tag(first = "unused")'
    )
    expect_fail_regex="expected one regular tag instance and/or one dev_dependency instance, got the dev_dependency instance before the regular instance: 'single_test_tag' tag at ${module_bazel_regex}:"
    ;;
  single-tag-fails-if-two-regular-tags)
    target='//:print-single-test-tag-values'
    tag_lines=(
      'test_ext.single_test_tag(first = "of two")'
      'test_ext.single_test_tag(second = "of two")'
    )
    expect_fail_regex="expected one regular tag instance and/or one dev_dependency instance, got two regular instances: 'single_test_tag' tag at ${module_bazel_regex}:"
    ;;
  single-tag-fails-if-two-dev-tags)
    target='//:print-single-test-tag-values'
    tag_lines=(
      'dev_test_ext.single_test_tag(first = "of two")'
      'dev_test_ext.single_test_tag(second = "of two")'
    )
    expect_fail_regex="expected one regular tag instance and/or one dev_dependency instance, got two dev_dependency instances: 'single_test_tag' tag at ${module_bazel_regex}:"
    ;;
  repeated-tag-values-for-zero-instances)
    target='//:print-repeated-test-tag-values'
    expect_regex='\{\}$'
    ;;
  repeated-tag-values-for-one-instance)
    target='//:print-repeated-test-tag-values'
    tag_lines=('test_ext.repeated_test_tag(unique_key = "foo", required = "bar")')
    expect_regex='\{"foo": \{"required": "bar", "optional": ""\}\}$'
    ;;
  repeated-tag-values-for-multiple-instances)
    target='//:print-repeated-test-tag-values'
    tag_lines=(
      'test_ext.repeated_test_tag(unique_key = "foo", required = "bar")'
      'test_ext.repeated_test_tag(unique_key = "baz", required = "quux", optional = "xyzzy")'
      'dev_test_ext.repeated_test_tag(unique_key = "plugh", required = "frobozz")'
    )
    expect_regex='\{"foo": \{"required": "bar", "optional": ""\}, "baz": \{"required": "quux", "optional": "xyzzy"\}, "plugh": \{"required": "frobozz", "optional": ""\}\}$'
    ;;
  repeated-tag-values-fails-on-duplicate-key)
    target='//:print-repeated-test-tag-values'
    tag_lines=(
      'test_ext.repeated_test_tag(unique_key = "foo", required = "bar")'
      'dev_test_ext.repeated_test_tag(unique_key = "foo", required = "baz")'
    )
    expect_fail_regex="multiple tags with same unique_key: 'repeated_test_tag' tag at ${module_bazel_regex}:"
    ;;
  fake-root-module-tags)
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
    ;;
  *)
    echo "Unknown case: ${case_name}" >&2
    exit 2
    ;;
esac

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
