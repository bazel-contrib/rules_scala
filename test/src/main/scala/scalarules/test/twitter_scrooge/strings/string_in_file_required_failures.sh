#!/usr/bin/env bash

set -euo pipefail

script="$1"

expect_read_error() {
  local expectation="$1" output

  if output="$(bash "${script}" "${expectation}" some_string does_not_exist.txt 2>&1)" ; then
    echo "ERROR: ${script} accepted an unreadable file with \"${expectation}\". Output: ${output}" >&2
    exit 1
  fi

  if ! grep -q 'Could not search' <<<"${output}" ; then
    echo "ERROR: ${script} failed with \"${expectation}\", but not on the unreadable file. Output: ${output}" >&2
    exit 1
  fi
}

expect_read_error false
expect_read_error true
