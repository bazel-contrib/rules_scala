#!/usr/bin/env bash
#
# Runs the binary the way a parent launcher does: JAVA_RUNFILES inherited from
# the environment, TEST_SRCDIR unset. The stub template skips runfiles
# discovery when JAVA_RUNFILES is set, so the launcher must not rely on
# TEST_SRCDIR to locate the Java runtime.

set -euo pipefail

echo "Executing: " "$@"
env -u TEST_SRCDIR JAVA_RUNFILES="${TEST_SRCDIR}" "$@"
