# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_unused_deps_filter_excluded_target() {
  bazel build //test_expect_failure/unused_dependency_checker/filtering:a \
    --extra_toolchains=//test_expect_failure/unused_dependency_checker/filtering:plus_one_unused_deps_filter
}

test_unused_deps_filter_included_target() {
  local test_target="//test_expect_failure/unused_dependency_checker/filtering:b"
  local expected_message="buildozer 'remove deps @[a-z_.~+-]*com_google_guava_guava_21_0//:com_google_guava_guava_21_0' ${test_target}"

  test_expect_failure_or_warning_on_missing_direct_deps_with_expected_message \
    "${expected_message}" ${test_target} \
    "--extra_toolchains=//test_expect_failure/unused_dependency_checker/filtering:plus_one_unused_deps_filter" \
    "eq"
}

$runner test_unused_deps_filter_excluded_target
$runner test_unused_deps_filter_included_target
