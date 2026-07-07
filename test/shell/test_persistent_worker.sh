#!/usr/bin/env bash

# shellcheck source=./test_runner.sh

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

PERSISTENT_WORKER_FLAGS=("--strategy=Scalac=worker")

if ! is_windows; then
  #Bazel sandboxing is not currently implemented in windows 
  PERSISTENT_WORKER_FLAGS+=("--worker_sandboxing")
fi

test_persistent_worker_success() {
  # shellcheck disable=SC2086
  bazel build //test:ScalaBinary "${PERSISTENT_WORKER_FLAGS[@]}"
}

test_persistent_worker_failure() {
  action_should_fail \
    build //test_expect_failure/diagnostics_reporter:error_file \
    "${PERSISTENT_WORKER_FLAGS[@]}"
}

$runner test_persistent_worker_success
$runner test_persistent_worker_failure
