# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

# fails unused dep

test_fails_for_unused_dep() {
  action_should_fail_with_message \
    "buildozer 'remove deps //test_expect_failure/compiler_dependency_tracker:E' //test_expect_failure/compiler_dependency_tracker:unused_dep" \
    build --extra_toolchains="//test_expect_failure/compiler_dependency_tracker:ast_plus_error" //test_expect_failure/compiler_dependency_tracker:unused_dep
}

test_fails_for_missing_compile_dep() {
  action_should_fail_with_message \
    "buildozer 'add deps //test_expect_failure/compiler_dependency_tracker:E' //test_expect_failure/compiler_dependency_tracker:missing_compile_dep" \
    build --extra_toolchains="//test_expect_failure/compiler_dependency_tracker:ast_plus_error" //test_expect_failure/compiler_dependency_tracker:missing_compile_dep
}

test_fails_for_strict_dep() {
  action_should_fail_with_message \
    "buildozer 'add deps //test_expect_failure/compiler_dependency_tracker:E' //test_expect_failure/compiler_dependency_tracker:missing_source_dep" \
    build --extra_toolchains="//test_expect_failure/compiler_dependency_tracker:ast_plus_error" //test_expect_failure/compiler_dependency_tracker:missing_source_dep
}

test_sdeps() {
  bazel test --extra_toolchains=//test_expect_failure/compiler_dependency_tracker:ast_plus_warn //test_expect_failure/compiler_dependency_tracker/sdeps/...
}

test_fails_without_warning() {
  cmd=$1
  expected=$2

  local output
  output=$($cmd 2>&1)

  if [ $? -eq 0 ]; then
    echo "Expected build to fail"
    echo "$output"
    exit 1
  fi

  echo "$output" | grep "$expected"
  if [ $? -eq 0 ]; then
    echo "Expected output:[$output] to not contain [$expected]"
    exit 1
  fi
}

test_no_unused_warn_when_broken() {
  action_should_fail_without_message \
    "remove deps" \
    build //test_expect_failure/compiler_dependency_tracker:F
}

# A Scala 3 target that uses an implicit summon resolved from a
# `given` import builds cleanly under the ast_plus_error toolchain.
# More targeted coverage of the underlying analyzer behavior lives in
# the AstUsedJarFinderTest.scala unit tests.
test_scala_3_given_import_is_not_unused() {
  bazel build \
    --extra_toolchains=//test_expect_failure/compiler_dependency_tracker:ast_plus_error \
    //test_expect_failure/compiler_dependency_tracker/given_imports:user
}

# Companion negative test. The :user_missing_given_dep target has the
# same source as :user but its deps omit the dep that provides the
# given. Compilation must fail with a "no given instance" error,
# anchoring the assumption that the given dep is genuinely required by
# :user.
test_scala_3_given_import_breaks_when_dep_removed() {
  action_should_fail_with_message \
    "No given instance" \
    build --extra_toolchains=//test_expect_failure/compiler_dependency_tracker:ast_plus_error //test_expect_failure/compiler_dependency_tracker/given_imports:user_missing_given_dep
}


$runner test_fails_for_unused_dep
$runner test_fails_for_missing_compile_dep
$runner test_fails_for_strict_dep
$runner test_sdeps
$runner test_no_unused_warn_when_broken
$runner test_scala_3_given_import_is_not_unused
$runner test_scala_3_given_import_breaks_when_dep_removed
