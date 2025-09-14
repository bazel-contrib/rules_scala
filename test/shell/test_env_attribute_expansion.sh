#!/usr/bin/env bash
#
# Tests that `scala_binary` properly expands `env` attribute values.
# See: scala/private/phases/phase_expand_environment.bzl

set -euo pipefail

dir="$( cd "${BASH_SOURCE[0]%/*}" && echo "${PWD%/test/shell}" )"
test_source="${dir}/test/shell/${BASH_SOURCE[0]#*test/shell/}"
# shellcheck source=./test_runner.sh
. "${dir}"/test/shell/test_runner.sh

setup_suite() {
  original_dir="$PWD"
  setup_test_tmpdir_for_file "$original_dir" "$test_source"
  test_tmpdir="$PWD"
  cd "$original_dir"

  bazel_bin=''
  if ! bazel_bin="$(command -v bazel)" &&
     ! bazel_bin="$(command -v bazel.exe)"; then
    printf 'bazel executable not found in: %s\n' "$PATH" >&2
    exit 1
  fi
}

teardown_suite() {
  rm -rf "$test_tmpdir"
}

test_scala_binary_env_attribute_expansion() {
  local bindir="$("$bazel_bin" info bazel-bin)"
  bindir="bazel-out/${bindir#*/bazel-out/}"

  "$bazel_bin" run //test:EnvAttributeBinary > "${test_tmpdir}/actual.txt"

  printf '%s\n' \
    'LOCATION: West of House' \
    'DATA_PATH: test/data/foo.txt' \
    'DEP_PATH: test/HelloLib.jar' \
    'SRC_PATH: test/EnvAttributeBinary.scala' \
    "BINDIR: ${bindir}" \
    'FROM_TOOLCHAIN_VAR: bazquux' \
    'ESCAPED: $(rootpath //test/data:foo.txt) $(BINDIR) $UNKNOWN' \
      > "${test_tmpdir}/expected.txt"

  diff -u --strip-trailing-cr "${test_tmpdir}"/{expected,actual}.txt
}

# If Bazel is actually bazel.exe, then Bash _will not_ export its environment
# variables to the Bazel process. In this case, we _must_ export them as
# Command Prompt variables.
_bazel_bat() {
  local bazel_bat="${test_tmpdir}/bazel.bat"

  printf '%s\n' \
    'set FROM_ENV_INHERIT=inherited value' \
    'set NOT_IN_ENV_INHERIT=inherited value' \
    'set FROM_ENV_INHERIT_AND_ENV_ATTR=inherited value' \
    'set FROM_ENV_INHERIT_AND_TEST_ENV=inherited value' \
    'set FROM_ALL_SOURCES=inherited value' \
    "bazel.exe %*" \
    > "$bazel_bat"
  bazel_bat="${bazel_bat#$PWD/}"
  cmd.exe '/c' "${bazel_bat//\//\\}" "$@"
}

_bazel_bash() {
  FROM_ENV_INHERIT="inherited value" \
    NOT_IN_ENV_INHERIT="inherited value" \
    FROM_ENV_INHERIT_AND_ENV_ATTR="inherited value" \
    FROM_ENV_INHERIT_AND_TEST_ENV="inherited value" \
    FROM_ALL_SOURCES="inherited value" \
    bazel "$@"
}

test_scala_test_env_attribute_with_env_inherit_and_test_env() {
  local bazel='_bazel_bash'

  if [[ "${bazel_bin##*.}" == 'exe' ]]; then
    bazel='_bazel_bat'
  fi

  "$bazel" test \
    --test_env=FROM_TEST_ENV="test env value" \
    --test_env=FROM_TEST_ENV_AND_ENV_ATTR="test env value" \
    --test_env=FROM_ENV_INHERIT_AND_TEST_ENV="test env value" \
    --test_env=FROM_ALL_SOURCES="test env value" \
    --test_output=all \
    //test:EnvAttributeManualTest
}

setup_suite
run_tests "$test_source" "$(get_test_runner "${1:-local}")"
teardown_suite
