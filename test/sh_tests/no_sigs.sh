#!/usr/bin/env bash

set -euo pipefail

lister="$1"
jar="$2"

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
