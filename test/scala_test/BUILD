load("//scala:scala.bzl", "scala_test")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_success_test")

scala_test(
    name = "a",
    srcs = ["A.scala"],
)

scala_test(
    name = "b",
    srcs = ["B.scala"],
    deps = [":a"],
)

# `b` doesn't declare a dep on scalatest, only on `:a`; scalatest is built into
# the scala_test rule itself. This asserts the unused-dependency checker
# doesn't falsely flag scalatest as an unused dep.
expect_build_success_test(
    name = "ast_analyzer_no_scalatest_unused_dep_warning_test",
    build_args = ["--extra_toolchains=//test/toolchains:ast_plus_one_deps_unused_deps_error"],
    target = ":b",
)

scala_test(
    name = "custom_reporter",
    srcs = [
        "A.scala",
        "CustomReporter.scala",
    ],
    reporter_class = "test.scala_test.CustomReporter",
)

# Check that we can run scala tests in external workspaces.
test_suite(
    name = "external_scala_test",
    tests = [
        "@example_external_workspace//test:empty_test",
    ],
)
