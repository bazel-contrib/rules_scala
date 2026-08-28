#!/usr/bin/env bash
set -euo pipefail

# Each manifest lists "original_source formatted_output" pairs, one per action
# output, both resolvable relative to our own runfiles root (see
# round_trip_test.bzl for why we read these directly).
base="${TEST_SRCDIR:?}/_main"

formatted_manifest="$base/$1"
unformatted_manifest="$base/$2"
unformatted_src_relpath="$3"
formatted_fixture_relpath="$4"

assert_all_formatted() {
  local manifest="$1"
  local orig out
  while read -r orig out; do
    [ -z "$orig" ] && continue
    if ! cmp -s "$base/$orig" "$base/$out"; then
      echo "FAIL: $orig should already be formatted" >&2
      exit 1
    fi
  done <"$manifest"
}

# Prints the fmt.output short path for $2's entry in manifest $1.
find_unformatted_output() {
  local manifest="$1"
  local target_src="$2"
  local orig out
  local any_unformatted=false
  local target_out=""
  while read -r orig out; do
    [ -z "$orig" ] && continue
    if ! cmp -s "$base/$orig" "$base/$out"; then
      any_unformatted=true
    fi
    if [ "$orig" = "$target_src" ]; then
      target_out="$out"
    fi
  done <"$manifest"
  if ! $any_unformatted; then
    echo "FAIL: $manifest should report at least one unformatted source" >&2
    exit 1
  fi
  if [ -z "$target_out" ]; then
    echo "FAIL: $manifest has no entry for $target_src" >&2
    exit 1
  fi
  echo "$target_out"
}

assert_all_formatted "$formatted_manifest"
unformatted_out=$(find_unformatted_output "$unformatted_manifest" "$unformatted_src_relpath")

if ! diff "$base/$unformatted_out" "$base/$formatted_fixture_relpath"; then
  echo "FAIL: formatting $unformatted_src_relpath did not produce $formatted_fixture_relpath" >&2
  exit 1
fi
