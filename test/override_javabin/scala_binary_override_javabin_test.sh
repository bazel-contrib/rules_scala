#!/usr/bin/env bash
#
# Verifies that scala_binary's launcher fails when JAVABIN is overridden to
# a nonexistent path: the launcher resolves the JVM through JAVABIN
# (see the "Set JAVABIN to the path to the JVM launcher" preamble Bazel's
# java_stub_template.txt generates).
#
# Usage: scala_binary_override_javabin_test.sh <launcher>

set -euo pipefail

launcher="${1:?Usage: scala_binary_override_javabin_test.sh <launcher>}"
bad_javabin="/etc/basdf"

if output="$(JAVABIN="${bad_javabin}" "${launcher}" 2>&1)"; then
  echo "${output}"
  echo "running ${launcher} with JAVABIN=${bad_javabin} should have failed but passed." >&2
  exit 1
fi

if [[ "${output}" != *"${bad_javabin}"* ]]; then
  echo "${output}"
  echo "expected the failure output to mention the bad JAVABIN path ${bad_javabin}." >&2
  exit 1
fi
