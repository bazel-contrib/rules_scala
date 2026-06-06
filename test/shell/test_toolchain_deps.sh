#!/usr/bin/env bash

# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
# shellcheck source=./scala_versions.sh
. "${dir}"/scala_versions.sh
runner=$(get_test_runner "${1:-local}")

test_semanticdb_toolchain_deps() {
  cd "${dir}/../.."
  for scala_version in "${scala_versions[@]}"; do
    bazel build //scala/private/toolchain_deps:semanticdb \
      --repo_env=SCALA_VERSION="${scala_version}"
  done
}

$runner test_semanticdb_toolchain_deps
