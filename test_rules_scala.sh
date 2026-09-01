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

# bazelci's shell_commands steps don't get its own --remote_cache /
# --google_default_credentials flags (remote_caching_flags in bazelci.py), so
# the bazel calls below share nothing with the separate "bazel test //..."
# step. Passed as argv, not written to .bazelrc: nested_bazel.sh's nested
# `bazel` invocations (run by the expect_* tests below) read this workspace's
# .bazelrc directly and would inherit it otherwise, serving intermediate
# outputs from the remote cache that never land in the nested output base --
# a nested test that reads one such output by path then fails with a
# NoSuchFileException that has nothing to do with what it actually tests.
#
# Excludes the last_green task: it runs a different (unreleased) Bazel
# binary than every other task, so it has nothing to share this cache with.
#
# Linux/Windows use RBE (Remote Build Execution); macOS runs on MacService
# instead of GCE (Google Compute Engine), so bazelci.py caches it through a
# GCS (Google Cloud Storage) bucket instead (still with
# --google_default_credentials).
remote_cache_flags=""
if [[ "${BUILDKITE:-}" == "true" ]] && [[ "${BAZELCI_TASK:-}" != *last_green* ]]; then
  if is_macos; then
    remote_cache_flags="--remote_cache=https://storage.googleapis.com/bazel-untrusted-build-cache --google_default_credentials --remote_timeout=3600 --remote_max_connections=200"
  else
    remote_cache_flags="--remote_cache=remotebuildexecution.googleapis.com --remote_instance_name=projects/bazel-untrusted/instances/default_instance --google_default_credentials --remote_max_connections=200"
  fi
fi

. "${test_dir}"/test_bzlmod_macros.sh
$runner bazel build $remote_cache_flags src/... test/...
#$runner bazel build src/... test/... --all_incompatible_changes
$runner bazel test $remote_cache_flags "${test_output_flag}" src/... test/...
$runner bazel test $remote_cache_flags "${test_output_flag}" third_party/...
$runner bazel build $remote_cache_flags --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_error -- test/...
$runner bazel build $remote_cache_flags --extra_toolchains=//scala:minimal_direct_source_deps -- test/...
#$runner bazel build --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_error --all_incompatible_changes -- test/...
$runner bazel test $remote_cache_flags "${test_output_flag}" --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_error -- test/...
$runner bazel test $remote_cache_flags "${test_output_flag}" --extra_toolchains=//scala:minimal_direct_source_deps -- test/...
$runner bazel build $remote_cache_flags test/missing_direct_deps/internal_deps/... --strict_java_deps=warn --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_warn
$runner bazel test $remote_cache_flags "$test_output_flag" //test/... --extra_toolchains="//test_expect_failure/plus_one_deps:plus_one_deps"
$runner bazel build $remote_cache_flags //test/binary_in_genrule:ScalaBinaryInGenrule --nolegacy_external_runfiles
$runner bazel build $remote_cache_flags //test_statsfile:Simple_statsfile
$runner bazel build $remote_cache_flags //test_statsfile:SimpleNoStatsFile_statsfile --extra_toolchains="//test/toolchains:enable_stats_file_disabled_toolchain"
. "${test_dir}"/test_scala_library.sh
