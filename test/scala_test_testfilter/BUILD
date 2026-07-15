load("//scala:scala.bzl", "scala_test")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_test_failure_test", "expect_test_success_test")

# `tests` bundles three suites, some of whose tests deliberately fail, so it is
# tagged "manual" (a plain `bazel test //...` would run the failing ones). The
# tests below drive nested `bazel test` runs asserting the right selection makes
# it pass, each paired with a negative control (same fixture, selection flag
# removed) that must fail -- proving the flag actually takes effect, not that it
# is silently ignored:
#   - class A: one passing test.
#   - class B: one failing test          -> excluded by the class-level --test_filter.
#   - class C: one passing + one failing  -> the failing one is excluded by the
#     method-level -t.
scala_test(
    name = "tests",
    srcs = [
        "A.scala",
        "B.scala",
        "C.scala",
    ],
    tags = ["manual"],
)

# Class-level selection: `--test_filter=A` runs only class A (all passing).
expect_test_success_test(
    name = "testfilter_class_selection",
    bazel_args = [
        "--test_output=errors",
        "--test_filter=A",
    ],
    target = ":tests",
)

# Negative control: with no filter the failing class B (and C's failing test) run,
# so the nested `bazel test` must fail.
expect_test_failure_test(
    name = "testfilter_class_selection_negative",
    bazel_args = ["--test_output=errors"],
    expect = ["expected_unfiltered_failure.txt"],
    target = ":tests",
)

# Method-level selection: `--test_filter=C` picks class C, and `-t "test 1"`
# narrows to its passing method, excluding C's failing "test 2".
expect_test_success_test(
    name = "testfilter_method_selection",
    bazel_args = [
        "--test_output=errors",
        "--test_filter=C",
        "--test_arg=-t",
        "--test_arg=test 1",
    ],
    target = ":tests",
)

# Negative control: selecting class C without the `-t` method filter also runs
# C's failing "test 2", so the nested `bazel test` must fail.
expect_test_failure_test(
    name = "testfilter_method_selection_negative",
    bazel_args = [
        "--test_output=errors",
        "--test_filter=C",
    ],
    expect = ["expected_method_unfiltered_failure.txt"],
    target = ":tests",
)
