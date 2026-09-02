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
# same in every sweep. This flag (see .bazelrc) skips it in the extra
# sweeps, since the default sweep above already checks it.
toolchain_sweep_flag="--config=toolchain-sweep"

. "${test_dir}"/test_bzlmod_macros.sh
$runner bazel build src/... test/...
#$runner bazel build src/... test/... --all_incompatible_changes
$runner bazel test "${test_output_flag}" src/... test/...
$runner bazel test "${test_output_flag}" third_party/...
$runner bazel build "${toolchain_sweep_flag}" --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_error -- test/...
$runner bazel build "${toolchain_sweep_flag}" --extra_toolchains=//scala:minimal_direct_source_deps -- test/...
#$runner bazel build --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_error --all_incompatible_changes -- test/...
$runner bazel test "${test_output_flag}" "${toolchain_sweep_flag}" --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_error -- test/...
$runner bazel test "${test_output_flag}" "${toolchain_sweep_flag}" --extra_toolchains=//scala:minimal_direct_source_deps -- test/...
$runner bazel build test/missing_direct_deps/internal_deps/... --strict_java_deps=warn --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_warn
$runner bazel test "${test_output_flag}" "${toolchain_sweep_flag}" //test/... --extra_toolchains="//test_expect_failure/plus_one_deps:plus_one_deps"
$runner bazel build //test/binary_in_genrule:ScalaBinaryInGenrule --nolegacy_external_runfiles
$runner bazel build //test_statsfile:Simple_statsfile
$runner bazel build //test_statsfile:SimpleNoStatsFile_statsfile --extra_toolchains="//test/toolchains:enable_stats_file_disabled_toolchain"
