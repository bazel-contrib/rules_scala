#!/usr/bin/env bash
#
# Verifies that LauncherFileWriter, which writes the Windows exe launcher,
# records `jacoco_main_class` in the launch info only when it is given a
# non-empty value, so the launcher exports JACOCO_MAIN_CLASS in coverage builds.

set -euo pipefail

# --- begin runfiles.bash initialization v3 ---
set +e
f=bazel_tools/tools/bash/runfiles/runfiles.bash
# shellcheck disable=SC1090
source "${RUNFILES_DIR:-/dev/null}/${f}" 2>/dev/null ||
  source "$(grep -sm1 "^${f} " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null ||
  source "$0.runfiles/${f}" 2>/dev/null ||
  source "$(grep -sm1 "^${f} " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null ||
  source "$(grep -sm1 "^${f} " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null ||
  {
    echo >&2 "ERROR: cannot find ${f}"
    exit 1
  }
set -e
# --- end runfiles.bash initialization v3 ---

writer="$(rlocation "${TEST_WORKSPACE:-_main}/src/java/io/bazel/rulesscala/exe/exe.exe")"
tmp="$(mktemp -d)"
trap 'rm -rf "${tmp}"' EXIT
# The writer is a Windows process, so it needs Windows style paths.
native_tmp="$(cygpath --mixed "${tmp}")"

echo "lib/a.jar;lib/b.jar" >"${tmp}/classpath"

write_launcher() {
  local output="$1"
  local start_class="$2"
  shift 2
  "${writer}" \
    "${native_tmp}/${output}" \
    _main \
    "local_jdk/bin/java.exe" \
    "${start_class}" \
    "${native_tmp}/classpath" \
    "-Dfoo=bar" \
    "$@"
}

write_launcher "plain" "example.Main"
if grep -aq "jacoco_main_class=" "${tmp}/plain"; then
  echo "expected no jacoco_main_class entry when none is given." >&2
  exit 1
fi
if ! grep -aq "java_start_class=example.Main" "${tmp}/plain"; then
  echo "expected java_start_class=example.Main in the launcher." >&2
  exit 1
fi

write_launcher "coverage" "com.google.testing.coverage.JacocoCoverageRunner" "example.Main"
if ! grep -aq "jacoco_main_class=example.Main" "${tmp}/coverage"; then
  echo "expected jacoco_main_class=example.Main in the launcher." >&2
  exit 1
fi
if ! grep -aq "java_start_class=com.google.testing.coverage.JacocoCoverageRunner" "${tmp}/coverage"; then
  echo "expected java_start_class=com.google.testing.coverage.JacocoCoverageRunner in the launcher." >&2
  exit 1
fi
