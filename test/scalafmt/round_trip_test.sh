#!/usr/bin/env bash
set -euo pipefail

formatted_test="$1"
unformatted_test="$2"
unformatted_format="$3"
unformatted_src="$4"
unformatted_src_relpath="$5"
formatted_src="$6"

# invoked via `bash` explicitly, not the shebang, since these targets need to
# run under bash on Windows too.
if ! bash "$formatted_test"; then
  echo "FAIL: $formatted_test should report the formatted target as already formatted" >&2
  exit 1
fi

if bash "$unformatted_test"; then
  echo "FAIL: $unformatted_test should report the unformatted target as not formatted" >&2
  exit 1
fi

# Run the formatter against a scratch copy instead of the real source tree,
# since $unformatted_format otherwise mutates $BUILD_WORKSPACE_DIRECTORY in place.
scratch="$TEST_TMPDIR/workspace"
mkdir -p "$scratch/$(dirname "$unformatted_src_relpath")"
cp "$unformatted_src" "$scratch/$unformatted_src_relpath"

bash "$unformatted_format" "$scratch"

if ! diff "$scratch/$unformatted_src_relpath" "$formatted_src"; then
  echo "FAIL: formatting $unformatted_src_relpath did not produce $formatted_src" >&2
  exit 1
fi
