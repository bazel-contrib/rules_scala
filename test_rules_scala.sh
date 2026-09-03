#!/usr/bin/env bash

set -e

if ! bazel_loc="$(type -p 'bazel')" || [[ -z "$bazel_loc" ]]; then
  export PATH="$(cd "$(dirname "$0")"; pwd)"/tools:$PATH
  echo 'Using ./tools/bazel directly for bazel calls'
fi

test_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/test/shell
# shellcheck source=./test_runner.sh
. "${test_dir}"/test_runner.sh
# shellcheck source=./test_helper.sh
. "${test_dir}"/test_helper.sh
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
# values ("toolchain sweeps"). A build_test tagged "skip-toolchain-sweep" has
# its own transition that already sets --extra_toolchains to one fixed value,
# so its result is the same in every sweep. These two flags skip it in the
# extra sweeps, combined with base_test_tag_filters above, since the default
# sweep already checks it.
toolchain_sweep_build_flag="--build_tag_filters=-skip-toolchain-sweep"
toolchain_sweep_test_flag="--test_tag_filters=${base_test_tag_filters:+${base_test_tag_filters},}-skip-toolchain-sweep"

# bazelci's `build_targets`/`test_targets` tasks get their own --remote_cache
# / --google_default_credentials flags (remote_caching_flags in bazelci.py);
# a `shell_commands` task like this one has to request the same cache itself
# to share it with the separate "bazel test //..." step. Requested here via
# --config=ci-cache-rbe/--config=ci-cache-gcs (defined in .bazelrc) on the
# top-level calls below only: nested_bazel.sh's nested `bazel` invocations
# (run by the expect_* tests below) read this workspace's .bazelrc directly
# and stay on its default configuration, keeping their own output base
# self-contained -- sharing the cache with them once had a nested test read
# an intermediate output the cache served that never actually landed in that
# output base, failing with a NoSuchFileException unrelated to what the test
# actually checks.
#
# Excludes the last_green task: it runs a different (unreleased) Bazel
# binary than every other task, so it has nothing to share this cache with.
remote_cache_config=""
if [[ "${BUILDKITE:-}" == "true" ]] && [[ "${BAZELCI_TASK:-}" != *last_green* ]]; then
  if is_macos; then
    remote_cache_config="--config=ci-cache-gcs"
  else
    remote_cache_config="--config=ci-cache-rbe"
  fi
fi

if [[ -z "${SKIP_DEFAULT_TOOLCHAIN_RUN:-}" ]]; then
  $runner bazel build $remote_cache_config src/... test/...
  #$runner bazel build src/... test/... --all_incompatible_changes
  $runner bazel test $remote_cache_config "${test_flags[@]}" src/... test/...
  $runner bazel test $remote_cache_config "${test_flags[@]}" third_party/...
fi
$runner bazel build $remote_cache_config "${toolchain_sweep_build_flag}" --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_error -- test/...
$runner bazel build $remote_cache_config "${toolchain_sweep_build_flag}" --extra_toolchains=//scala:minimal_direct_source_deps -- test/...
#$runner bazel build --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_error --all_incompatible_changes -- test/...
$runner bazel test $remote_cache_config "${test_output_flag}" "${toolchain_sweep_test_flag}" --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_error -- test/...
$runner bazel test $remote_cache_config "${test_output_flag}" "${toolchain_sweep_test_flag}" --extra_toolchains=//scala:minimal_direct_source_deps -- test/...
$runner bazel build $remote_cache_config test/missing_direct_deps/internal_deps/... --strict_java_deps=warn --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_warn
$runner bazel test $remote_cache_config "${test_output_flag}" "${toolchain_sweep_test_flag}" //test/... --extra_toolchains="//test_expect_failure/plus_one_deps:plus_one_deps"
$runner bazel build $remote_cache_config //test/binary_in_genrule:ScalaBinaryInGenrule --nolegacy_external_runfiles
$runner bazel build $remote_cache_config //test_statsfile:Simple_statsfile
$runner bazel build $remote_cache_config //test_statsfile:SimpleNoStatsFile_statsfile --extra_toolchains="//test/toolchains:enable_stats_file_disabled_toolchain"
