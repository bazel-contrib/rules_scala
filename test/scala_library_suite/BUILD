# Migrated from test/shell/test_scala_library.sh.

load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test")

package(default_testonly = 1)

expect_build_failure_test(
    name = "scala_library_suite",
    expect = ["expected_invalid_scala.txt"],
    target = "//test_expect_failure/scala_library_suite:library_suite_dep_on_children",
)
