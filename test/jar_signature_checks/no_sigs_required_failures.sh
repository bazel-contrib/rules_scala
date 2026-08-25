#!/usr/bin/env bash

set -euo pipefail

script="$1"
lister="$2"
signed_jar="$3"

expect_rejected() {
  local jar="$1" expected="$2" output

  if output="$(bash "${script}" "${lister}" "${jar}" 2>&1)" ; then
    echo "ERROR: ${script} accepted ${jar}. Output: ${output}" >&2
    exit 1
  fi

  if ! grep -q "${expected}" <<<"${output}" ; then
    echo "ERROR: ${script} rejected ${jar}, but not with \"${expected}\". Output: ${output}" >&2
    exit 1
  fi
}

expect_rejected does_not_exist.jar 'Could not list'
expect_rejected "${signed_jar}" 'Found signature files'
