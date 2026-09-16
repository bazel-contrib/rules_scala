#!/usr/bin/env bash
#
# Builds test/... plus the coverage-instrumented test/coverage_* packages
# twice from scratch, with a fresh --disk_cache the second time, and diffs
# md5 hashes of every jar -- proves the build is reproducible independent
# of caching.

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

nested_bazel_setup "rules_scala_reproducibility_output_base"

md5_util() {
  if [[ "${OSTYPE}" == "darwin"* ]]; then
    echo "md5"
  else
    echo "md5sum"
  fi
}

# Discovered via glob so this list stays correct when a test/coverage_*
# package is added, renamed, or removed.
coverage_packages=()
for package_dir in test/coverage_*; do
  coverage_packages+=("//${package_dir}/...")
done

# jmh's code generator is non-deterministic, so its jars are excluded here;
# every other jar, including *_deploy.jar, is checked (singlejar normalizes
# zip entry timestamps to a fixed date, so deploy jars are reproducible too).
jar_md5_sum() {
  local bazel_bin
  bazel_bin="$(nested_bazel_run info bazel-bin)"
  find "${bazel_bin}/test" -name '*.jar' ! -path "${bazel_bin}/test/jmh/*" \
    | xargs -n 1 -P 5 "$(md5_util)" | sort
}

hash1="$(mktemp)"
hash2="$(mktemp)"

nested_bazel_run clean
nested_bazel_run build test/...
nested_bazel_run build --collect_code_coverage -- "${coverage_packages[@]}"
jar_md5_sum > "${hash1}"

nested_bazel_run clean
sleep 10 # make sure timestamp-based nondeterminism, if any, would show up as different timestamps

disk_cache_dir="$(mktemp -d)"
nested_bazel_run build "--disk_cache=${disk_cache_dir}" test/...
nested_bazel_run build "--disk_cache=${disk_cache_dir}" --collect_code_coverage -- "${coverage_packages[@]}"
jar_md5_sum > "${hash2}"

if ! diff "${hash1}" "${hash2}"; then
  echo "The jar(s) above have a different md5 between the two builds -- rebuild is not reproducible." >&2
  exit 1
fi
