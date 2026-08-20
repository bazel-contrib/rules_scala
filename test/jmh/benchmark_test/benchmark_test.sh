#!/usr/bin/env bash
#
# Runs a JMH benchmark binary with a minimal iteration count and checks it
# printed a result line, exercising the scala_benchmark_jmh wiring end to end.
#
# Usage:
#   benchmark_test.sh <path-to-benchmark-binary>

set -euo pipefail

benchmark="${1:?Usage: benchmark_test.sh <path-to-benchmark-binary>}"

output="$("${benchmark}" -i1 -f1 -wi 1)"

if [[ "${output}" != *Result*Benchmark* ]]; then
  echo "Benchmark did not produce expected output:" >&2
  echo "${output}" >&2
  exit 1
fi
