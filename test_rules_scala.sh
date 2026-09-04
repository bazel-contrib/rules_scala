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
# values ("toolchain sweeps"). A build_test tagged "skip-toolchain-sweep" has
# its own transition that already sets --extra_toolchains to one fixed value,
# so its result is the same in every sweep. These two flags skip it in the
# extra sweeps, combined with base_test_tag_filters above, since the default
# sweep already checks it.
toolchain_sweep_build_flag="--build_tag_filters=-skip-toolchain-sweep"
toolchain_sweep_test_flag="--test_tag_filters=${base_test_tag_filters:+${base_test_tag_filters},}-skip-toolchain-sweep"

# The --extra_toolchains lines below each build/test a toolchain config that no
# other CI task exercises, so there's nothing else for Bazel to reuse -- but
# unlike a build_targets/test_targets task, a shell_commands task like this one
# (bazelci.py's execute_shell_commands()) gets no remote-cache flags for free.
# Add them ourselves, gated by RULES_SCALA_REMOTE_CACHE=<platform>, so repeated
# CI runs of this script reuse each other's cache instead of always starting
# from empty.
remote_cache_flags=()
if [[ -n "${RULES_SCALA_REMOTE_CACHE:-}" ]]; then
  buildkite_org="${BUILDKITE_ORGANIZATION_SLUG:-bazel}"
  cloud_project=bazel-untrusted
  bucket_id=untrusted
  if [[ "$buildkite_org" == bazel-trusted ]]; then
    cloud_project=bazel-public
    bucket_id=trusted
  fi
  sha256() { if command -v sha256sum >/dev/null; then sha256sum; else shasum -a 256; fi; }
  # A tag we own, not bazelci.py's "cache-poisoning-<date>" one: this cache is
  # only ever read/written by this script's own runs, so there's no upstream
  # tag to track or fall out of sync with.
  silo_key=$(printf '%s:test_rules_scala.sh-extra-toolchains-v1:%s:' \
    "$buildkite_org" "$RULES_SCALA_REMOTE_CACHE" | sha256 | cut -d' ' -f1)
  if [[ "$RULES_SCALA_REMOTE_CACHE" == macos ]]; then
    remote_cache_flags=(
      "--remote_cache=https://storage.googleapis.com/bazel-${bucket_id}-build-cache"
      "--google_default_credentials"
      "--remote_timeout=3600"
    )
  else
    remote_cache_flags=(
      "--remote_cache=remotebuildexecution.googleapis.com"
      "--remote_instance_name=projects/${cloud_project}/instances/default_instance"
      "--google_default_credentials"
      "--bes_backend=buildeventservice.googleapis.com"
      "--bes_results_url=https://btx.cloud.google.com/invocations/"
      "--bes_timeout=360s"
      "--bes_instance_name=${cloud_project}"
      "--remote_timeout=60"
    )
  fi
  remote_cache_flags+=(
    "--remote_max_connections=200"
    "--remote_default_exec_properties=cache-silo-key=${silo_key}"
  )
fi

$runner bazel build src/... test/...
#$runner bazel build src/... test/... --all_incompatible_changes
$runner bazel test "${test_flags[@]}" src/... test/...
$runner bazel test "${test_flags[@]}" third_party/...
$runner bazel build "${toolchain_sweep_build_flag}" "${remote_cache_flags[@]}" --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_error -- test/...
$runner bazel build "${toolchain_sweep_build_flag}" "${remote_cache_flags[@]}" --extra_toolchains=//scala:minimal_direct_source_deps -- test/...
#$runner bazel build --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_error --all_incompatible_changes -- test/...
$runner bazel test "${test_output_flag}" "${toolchain_sweep_test_flag}" "${remote_cache_flags[@]}" --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_error -- test/...
$runner bazel test "${test_output_flag}" "${toolchain_sweep_test_flag}" "${remote_cache_flags[@]}" --extra_toolchains=//scala:minimal_direct_source_deps -- test/...
$runner bazel build "${remote_cache_flags[@]}" test/missing_direct_deps/internal_deps/... --strict_java_deps=warn --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_warn
$runner bazel test "${test_output_flag}" "${toolchain_sweep_test_flag}" "${remote_cache_flags[@]}" //test/... --extra_toolchains="//test_expect_failure/plus_one_deps:plus_one_deps"
$runner bazel build //test/binary_in_genrule:ScalaBinaryInGenrule --nolegacy_external_runfiles
$runner bazel build //test_statsfile:Simple_statsfile
$runner bazel build "${remote_cache_flags[@]}" //test_statsfile:SimpleNoStatsFile_statsfile --extra_toolchains="//test/toolchains:enable_stats_file_disabled_toolchain"
