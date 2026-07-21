load("//scala:scala.bzl", "scala_test")

scala_test(
    name = "a",
    srcs = ["A.scala"],
)

# `b` doesn't declare a dep on scalatest, only on `:a`; scalatest is built into
# the scala_test rule itself. The test asserting the unused-dependency checker
# doesn't falsely flag scalatest as an unused dep lives in
# //test/unused_dependency_checker (not here) so that this package does not
# load @rules_shell (a dev-only dependency, invisible when rules_scala is
# consumed as a module) -- matching //test/jmh's precedent.
scala_test(
    name = "b",
    srcs = ["B.scala"],
    deps = [":a"],
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
