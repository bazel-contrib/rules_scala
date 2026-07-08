load("//scala:scala.bzl", "scala_test")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_test_success_test")

# `tests` bundles class A (passing) and class B (deliberately failing). It is
# tagged "manual" so a plain `bazel test //...` doesn't run the failing B; the
# tests below drive nested `bazel test` runs with a --test_filter that selects
# only A and assert they pass, proving the filter excludes B.
scala_test(
    name = "tests",
    srcs = [
        "A.scala",
        "B.scala",
    ],
    tags = ["manual"],
)

# Class-level selection: `--test_filter=A` runs only class A's tests.
expect_test_success_test(
    name = "testfilter_class_selection",
    bazel_args = [
        "--test_output=errors",
        "--test_filter=A",
    ],
    target = ":tests",
)

# Method-level selection: additionally pass `-t "test 1"` to the ScalaTest runner.
expect_test_success_test(
    name = "testfilter_method_selection",
    bazel_args = [
        "--test_output=errors",
        "--test_filter=A",
        "--test_arg=-t",
        "--test_arg=test 1",
    ],
    target = ":tests",
)
