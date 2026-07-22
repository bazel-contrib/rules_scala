# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_succeeds_with_warning() {
  cmd=$1
  expected=$2

  local output
  output=$($cmd 2>&1)

  if [ $? -ne 0 ]; then
    echo "Target with unused dependency failed to build with status $?"
    echo "$output"
    exit 1
  fi

  echo "$output" | grep "$expected"
  if [ $? -ne 0 ]; then
    echo "Expected output:[$output] to contain [$expected]"
    exit 1
  fi
}

test_unused_dependency_fails_even_if_also_exists_in_plus_one_deps() {
  action_should_fail build --extra_toolchains="//test_expect_failure/plus_one_deps:plus_one_deps_with_unused_error" //test_expect_failure/plus_one_deps/with_unused_deps:a
}

test_plus_one_ast_analyzer_unused_deps_error() {
  action_should_fail build --extra_toolchains="//test/toolchains:ast_plus_one_deps_unused_deps_error" //test_expect_failure/plus_one_deps/with_unused_deps:a
}

test_plus_one_ast_analyzer_unused_deps_strict_deps_error() {
  action_should_fail build --extra_toolchains="//scala:minimal_direct_source_deps" //test_expect_failure/plus_one_deps/with_unused_deps:a
}

test_plus_one_ast_analyzer_unused_deps_warn() {
  test_succeeds_with_warning \
    "bazel build --extra_toolchains=//test/toolchains:ast_plus_one_deps_unused_deps_warn //test_expect_failure/plus_one_deps/with_unused_deps:a" \
    "warning: Target '//test_expect_failure/plus_one_deps/with_unused_deps:c' is specified as a dependency to //test_expect_failure/plus_one_deps/with_unused_deps:a but isn't used, please remove it from the deps."
}

test_plus_one_ast_analyzer_unused_deps_scala_test() {
  # We should not emit an unuse dep warning for scalatest library in a scala_test rule
  # even when the rule does not directly depend on scalatest. As scalatest is built into
  # the scala_test library.
  bazel build --extra_toolchains="//test/toolchains:ast_plus_one_deps_unused_deps_error" //test/scala_test:b
}

$runner test_unused_dependency_fails_even_if_also_exists_in_plus_one_deps
$runner test_plus_one_ast_analyzer_unused_deps_error
$runner test_plus_one_ast_analyzer_unused_deps_strict_deps_error
$runner test_plus_one_ast_analyzer_unused_deps_warn
$runner test_plus_one_ast_analyzer_unused_deps_scala_test
