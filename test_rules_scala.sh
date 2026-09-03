#!/usr/bin/env bash

set -e

if ! bazel_loc="$(type -p 'bazel')" || [[ -z "$bazel_loc" ]]; then
  export PATH="$(cd "$(dirname "$0")"; pwd)"/tools:$PATH
  echo 'Using ./tools/bazel directly for bazel calls'
fi

test_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/test/shell
# shellcheck source=./test_runner.sh
. "${test_dir}"/test_runner.sh
runner=$(get_test_runner "${1:-local}")
test_output_flag="--test_output=errors"
# `RULES_SCALA_TEST_TAG_FILTERS`: an extra `--test_tag_filters` value for
# every `bazel test` below (e.g. the last_green CI job sets this to skip its
# own downstream-consumer tests). Kept out of `--test_tag_filters` itself so
# a caller's own value and the toolchain-sweep flags below can both apply:
# Bazel keeps only the last `--test_tag_filters` it sees on one command line,
# so passing two would silently drop one of them.
base_test_tag_filters="${RULES_SCALA_TEST_TAG_FILTERS:-}"
test_flags=("${test_output_flag}")
if [[ -n "${base_test_tag_filters}" ]]; then
  test_flags+=("--test_tag_filters=${base_test_tag_filters}")
fi

# The lines below run test/... again under different --extra_toolchains
# values ("toolchain sweeps"). A "fixed-toolchain" build_test's own transition
# already sets --extra_toolchains to one fixed value, so its result is the
# same in every sweep. These two flags skip it in the extra sweeps, combined
# with base_test_tag_filters above, since the default sweep already checks it.
toolchain_sweep_build_flag="--build_tag_filters=-fixed-toolchain"
toolchain_sweep_test_flag="--test_tag_filters=${base_test_tag_filters:+${base_test_tag_filters},}-fixed-toolchain"

. "${test_dir}"/test_bzlmod_macros.sh
$runner bazel build src/... test/...
#$runner bazel build src/... test/... --all_incompatible_changes
$runner bazel test "${test_flags[@]}" src/... test/...
$runner bazel test "${test_flags[@]}" third_party/...
$runner bazel build "${toolchain_sweep_build_flag}" --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_error -- test/...
$runner bazel build "${toolchain_sweep_build_flag}" --extra_toolchains=//scala:minimal_direct_source_deps -- test/...
#$runner bazel build --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_error --all_incompatible_changes -- test/...
$runner bazel test "${test_output_flag}" "${toolchain_sweep_test_flag}" --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_error -- test/...
$runner bazel test "${test_output_flag}" "${toolchain_sweep_test_flag}" --extra_toolchains=//scala:minimal_direct_source_deps -- test/...
$runner bazel build test/missing_direct_deps/internal_deps/... --strict_java_deps=warn --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_warn
$runner bazel test "${test_output_flag}" "${toolchain_sweep_test_flag}" //test/... --extra_toolchains="//test_expect_failure/plus_one_deps:plus_one_deps"
$runner bazel build //test/binary_in_genrule:ScalaBinaryInGenrule --nolegacy_external_runfiles
$runner bazel build //test_statsfile:Simple_statsfile
$runner bazel build //test_statsfile:SimpleNoStatsFile_statsfile --extra_toolchains="//test/toolchains:enable_stats_file_disabled_toolchain"
