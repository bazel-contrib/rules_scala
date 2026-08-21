#!/usr/bin/env bash

set -euo pipefail

lister="$1"
# The py_binary launcher does not run with the test's working directory on
# Windows, so a rootpath argument has to be made absolute before it is passed on.
jar="${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/$2"

# A listing that never got produced looks the same as a jar without signature
# files, so a lister that failed would pass this test for free.
if ! listing="$("${lister}" "${jar}")" ; then
  echo "ERROR: Could not list ${jar}." >&2
  exit 1
fi

if signatures="$(grep -E 'DSA|RSA' <<<"${listing}")" ; then
  echo "ERROR: Found signature files in ${jar}:" >&2
  echo "${signatures}" >&2
  exit 1
fi
