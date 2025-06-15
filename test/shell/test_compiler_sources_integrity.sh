#!/usr/bin/env bash
#
# Reproduces and validates the fix for bazel-contrib/rules_scala#1743.
#
# Specifically, we must not emit "canonical reproducible form" warnings for
# known Scala versions when enabling dependency tracking via:
#
#   scala_config.settings(
#       enable_compiler_dependency_tracking = True,
#   )
#
# Instead, we fail the build with a message describing how to use
# scala_deps.compiler_srcjar to provide an "integrity" value.
#
# See:
#
# - _get_compiler_srcjar() from scala/private/macros/scala_repositories.bzl
# - scala/private/macros/compiler_sources_integrity.bzl
# - scripts/update_compiler_sources_integrity.py

set -euo pipefail

dir="$( cd "${BASH_SOURCE[0]%/*}" && echo "${PWD%/test/shell}" )"
test_source="${dir}/test/shell/${BASH_SOURCE[0]#*test/shell/}"
# shellcheck source=./test_runner.sh
. "${dir}"/test/shell/test_runner.sh
. "${dir}"/test/shell/test_helper.sh
export USE_BAZEL_VERSION=${USE_BAZEL_VERSION:-$(cat $dir/.bazelversion)}

# Setup and teardown

_clean() {
  bazel clean --expunge_async >/dev/null 2>&1
}

setup_suite() {
  local output

  original_dir="$PWD"
  cd "${dir}/test/compiler_sources_integrity"

  local bk_bazel_rc="${dir}/tools/bazel.rc"

  if [[ -f "$bk_bazel_rc" ]]; then
    # test_rules_scala_jdk21 from .bazelci/presubmit.yml needs this.
    mkdir tools
    cp "${bk_bazel_rc}" tools/
  fi

  # The behavior we're testing must not rely on repos generated during previous
  # builds or test runs.
  _clean
}

teardown_suite() {
  _clean
  cd "$original_dir"
}

# Helpers and assertions

_REPO_PREFIX='https://repo1.maven.org/maven2/org/scala-lang'

_scala_2_url() {
  local scala_version="$1"
  printf '%s/scala-compiler/%s/scala-compiler-%s-sources.jar' \
    "$_REPO_PREFIX" "$scala_version" "$scala_version"
}

_scala_3_url() {
  local scala_version="$1"
  printf '%s/scala3-compiler_3/%s/scala3-compiler_3-%s-sources.jar' \
    "$_REPO_PREFIX" "$scala_version" "$scala_version"
}

_build_with_scala_version() {
  local scala_version="${1:-}"
  local build_args=()

  if [[ -n "$scala_version" ]]; then
    build_args+=("--repo_env=SCALA_VERSION=${scala_version}")
  fi

  # Because the macOS BuildKite runner apparently uses an older Bash, leading to
  # `build_args[@]` being unbound when empty:
  # - https://stackoverflow.com/a/7577209
  bazel build ${build_args[@]+"${build_args[@]}"} //... 2>&1
}

_expect_success_without_canonical_reproducible_warning() {
  local crf_warning="canonical reproducible form"
  local output

  if ! output="$(_build_with_scala_version "$@")"; then
    echo "$output"
    fail " build failed"
  elif [[ "$output" =~ $crf_warning ]]; then
    echo "$output"
    fail " build output contained \"${crf_warning}\" warning"
  elif verbose_test_output; then
    echo "$output"
    echo -e "${GREEN} \"bazel $*\" output didn't contain \"${crf_warning}\".$NC"
  fi
}

_FAILED_MSG='No compiler source jar integrity data exists'

_expect_failure_with_guessed_url() {
  local scala_version="$1"
  local guessed_url="$2"
  local output

  if output="$(_build_with_scala_version "$scala_version")"; then
    echo "$output"
    fail " SCALA_VERSION=${scala_version} build didn't fail"
  elif [[ ! "$output" =~ $_FAILED_MSG ]]; then
    echo "$output"
    fail " error message didn't contain \"${_FAILED_MSG}\""
  elif [[ ! "$output" =~ $guessed_url ]]; then
    echo "$output"
    fail " error message didn't contain \"${guessed_url}\""
  elif verbose_test_output; then
    echo "$output"
    echo -e "${GREEN} error message contained \"${_FAILED_MSG}\""
    echo -e " and \"${guessed_url}\".$NC"
  fi
}

# Test cases

test_emit_no_canonical_reproducible_form_warning_for_default_version() {
  _expect_success_without_canonical_reproducible_warning
}

test_emit_no_canonical_reproducible_form_warning_for_latest_versions() {
  local scala_version_pattern='^scala_version = "([0-9.]+)"$'
  local f
  local line
  local version
  local versions=()

  for f in "${dir}"/third_party/repositories/scala_*.bzl; do
    while IFS= read -r line; do
      if [[ "$line" =~ $scala_version_pattern ]]; then
        versions+=("${BASH_REMATCH[1]}")
        break
      fi
    done <"$f"
  done

  for version in "${versions[@]}"; do
    _expect_success_without_canonical_reproducible_warning "$version"
  done
}

test_emit_no_canonical_reproducible_form_warning_for_user_srcjar() {
  # Uses a bogus version not in compiler_sources_integrity.bzl, so we know the
  # build's relying on the user defined compiler_srcjar. That compiler_srcjar
  # instance uses a real URL to ensure the build succeeds for this test case.
  _expect_success_without_canonical_reproducible_warning "3.1.999"
}

test_fail_if_missing_compiler_source_integrity() {
  # A value not in scala/private/macros/compiler_sources_integrity.bzl nor
  # configured as a compiler_srcjar in MODULE.bazel or WORKSPACE.
  local scala_version='2.13.999'
  local guessed_url="$(_scala_2_url "$scala_version")"

  _expect_failure_with_guessed_url "$scala_version" "$guessed_url"
}

test_fail_with_scala3_compiler_source_link() {
  # A value not in scala/private/macros/compiler_sources_integrity.bzl nor
  # configured as a compiler_srcjar in MODULE.bazel or WORKSPACE.
  local scala_version='3.7.999'
  local guessed_url="$(_scala_3_url "$scala_version")"

  _expect_failure_with_guessed_url "$scala_version" "$guessed_url"
}

test_fail_with_scala3_compiler_source_link_for_unknown_major_version() {
  # A value not in scala/private/macros/compiler_sources_integrity.bzl that's
  # beyond the current highest major version. For now we sort of fake it with a
  # Scala 3 URL, but if/when Scala 4 launches, this will prompt us to update it.
  local scala_version='4.0.999'
  local guessed_url="$(_scala_3_url "$scala_version")"

  _expect_failure_with_guessed_url "$scala_version" "$guessed_url"
}

# main()

setup_suite
run_tests "$test_source" "$(get_test_runner "${1:-local}")"
teardown_suite
