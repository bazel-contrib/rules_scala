#!/usr/bin/env bash
#
# Builds test/... plus the coverage-instrumented test/coverage_* packages
# twice from scratch, with a fresh --disk_cache the second time, and diffs
# md5 hashes of every non-deploy jar -- proves the build is reproducible
# independent of caching.

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

# Collected dynamically so new/renamed/removed test/coverage_* packages
# need no change here.
coverage_packages=()
for package_dir in test/coverage_*; do
  coverage_packages+=("//${package_dir}/...")
done

non_deploy_jar_md5_sum() {
  local bazel_bin
  bazel_bin="$(nested_bazel_run info bazel-bin)"
  find "${bazel_bin}/test" -name '*.jar' ! -name '*_deploy.jar' ! -path "${bazel_bin}/test/jmh/*" \
    | xargs -n 1 -P 5 "$(md5_util)" | sort
}

hash1="$(mktemp)"
hash2="$(mktemp)"

nested_bazel_run clean
nested_bazel_run build test/...
nested_bazel_run build --collect_code_coverage -- "${coverage_packages[@]}"
non_deploy_jar_md5_sum > "${hash1}"

nested_bazel_run clean
sleep 10 # make sure timestamp-based nondeterminism, if any, would show up as different timestamps

disk_cache_dir="$(mktemp -d)"
nested_bazel_run build "--disk_cache=${disk_cache_dir}" test/...
nested_bazel_run build "--disk_cache=${disk_cache_dir}" --collect_code_coverage -- "${coverage_packages[@]}"
non_deploy_jar_md5_sum > "${hash2}"

diff "${hash1}" "${hash2}"
