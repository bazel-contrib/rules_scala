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
# The lines below run test/... again under different --extra_toolchains
# values ("toolchain sweeps"). A "fixed-toolchain" build_test's own transition
# already sets --extra_toolchains to one fixed value, so its result is the
# same in every sweep. These two flags skip it in the extra sweeps, since
# the default sweep above already checks it.
#
# A CI job that needs its own --test_tag_filters value too (e.g. to also
# skip some other tests) writes that value to .extra_test_tag_filters
# before calling this script, instead of passing --test_tag_filters
# itself: Bazel keeps only the last --test_tag_filters value it sees, so a
# second one here would silently replace the job's own value instead of
# adding to it.
extra_test_tag_filters=""
if [[ -f .extra_test_tag_filters ]]; then
  extra_test_tag_filters=$(cat .extra_test_tag_filters)
fi
toolchain_sweep_build_flag="--build_tag_filters=-fixed-toolchain"
toolchain_sweep_test_flag="--test_tag_filters=${extra_test_tag_filters:+${extra_test_tag_filters},}-fixed-toolchain"

. "${test_dir}"/test_bzlmod_macros.sh
$runner bazel build src/... test/...
#$runner bazel build src/... test/... --all_incompatible_changes
$runner bazel test "${test_output_flag}" src/... test/...
$runner bazel test "${test_output_flag}" third_party/...
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
