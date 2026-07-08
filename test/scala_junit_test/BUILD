load("//scala:scala.bzl", "scala_junit_test", "scala_specs2_junit_test")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_test_failure_test")

# These scala_junit_test fixtures are each expected to fail when run, so they are
# tagged "manual" (a failing test would break wildcard `bazel test //...`); the
# expect_test_failure_test targets drive a nested `bazel test` and assert it fails.

# A JUnit test whose method throws must report a test failure.
scala_junit_test(
    name = "failing_test",
    size = "small",
    srcs = ["JunitFailureTest.scala"],
    suffixes = ["Test"],
    tags = ["manual"],
)

# A scala_junit_test must declare a class prefix or suffix; without one it fails.
scala_junit_test(
    name = "no_prefix_or_suffix",
    size = "small",
    srcs = ["JunitTest.scala"],
    tags = ["manual"],
)

# A suffix that matches no class must error with "no tests found".
scala_junit_test(
    name = "no_tests_found",
    size = "small",
    srcs = ["JunitTest.scala"],
    suffixes = ["DoesNotMatch"],
    tags = ["manual"],
)

expect_test_failure_test(
    name = "failing_test_fails",
    target = ":failing_test",
)

expect_test_failure_test(
    name = "no_prefix_or_suffix_fails",
    target = ":no_prefix_or_suffix",
)

expect_test_failure_test(
    name = "no_tests_found_fails",
    target = ":no_tests_found",
)

# A specs2 suite whose class cannot be instantiated. Tagged "manual" (it fails
# when run); the tests below drive nested `bazel test` runs and assert the
# specs2 UserException surfaces.
scala_specs2_junit_test(
    name = "specs2_failing_test",
    size = "small",
    srcs = [
        "specs2/FailingTest.scala",
        "specs2/SuiteWithOneFailingTest.scala",
    ],
    suffixes = ["Test"],
    tags = ["manual"],
)

# Without a filter the failing spec's initializer throws; the run must fail with
# the specs2 UserException.
expect_test_failure_test(
    name = "specs2_exception_in_initializer_fails",
    bazel_args = [
        "--nocache_test_results",
        "--test_output=streamed",
    ],
    expect = ["expected_specs2_user_exception.txt"],
    target = ":specs2_failing_test",
)

# Filtering to the failing spec must surface the same exception and terminate
# promptly (no test-timeout), i.e. the run fails fast rather than hanging.
expect_test_failure_test(
    name = "specs2_exception_terminates_without_timeout",
    bazel_args = [
        "--nocache_test_results",
        "--test_output=streamed",
        "--test_timeout=10",
        "--test_filter=scalarules.test.junit.specs2.FailingTest#",
    ],
    expect = ["expected_specs2_user_exception.txt"],
    reject = ["rejected_timeout.txt"],
    target = ":specs2_failing_test",
)
