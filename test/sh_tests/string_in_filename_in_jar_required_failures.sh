#!/usr/bin/env bash

# Required-failure cases for string_in_filename_in_jar.sh. Its "false"
# expectation reports a pass for anything other than a match, so every way its
# inputs can go wrong has to fail loudly instead.

set -euo pipefail

script="$1"
jar_name="$2"
# Only the directory of this path is used, so any of the target's files will do.
jar_sibling="$3"

stub_dir="$(mktemp -d)"
trap 'rm -rf "${stub_dir}"' EXIT
printf '#!/bin/sh\nexit 2\n' > "${stub_dir}/grep"
chmod +x "${stub_dir}/grep"

expect_failure() {
  local description="$1" expected="$2" output
  shift 2

  if output="$("$@" 2>&1)" ; then
    echo "ERROR: ${description} passed. Output: ${output}" >&2
    exit 1
  fi

  if ! grep -qF -- "${expected}" <<<"${output}" ; then
    echo "ERROR: ${description} failed without \"${expected}\". Output: ${output}" >&2
    exit 1
  fi
}

for expectation in true false ; do
  expect_failure "an unreadable jar with \"${expectation}\"" "Could not list" \
    sh "${script}" "${expectation}" does_not_exist.jar thrift999 "${jar_sibling}"

  expect_failure "a failing grep with \"${expectation}\"" "Could not search" \
    env PATH="${stub_dir}:${PATH}" sh "${script}" "${expectation}" "${jar_name}" thrift999 "${jar_sibling}"
done

# A pattern with a space has to stay one literal string, instead of becoming a
# second grep argument that grep reads as a file.
expect_failure "a literal pattern with a space" "Not found file" \
  sh "${script}" true "${jar_name}" "thrift999 namespace" "${jar_sibling}"
