load("//test/expect_build_failure:expect_build_failure.bzl", "expect_test_success_test")

package(default_testonly = 1)

# --test_output=all is needed so expect/reject below can grep the test's stdout.
expect_test_success_test(
    name = "test_filter_wildcard_test",
    target = "//test:TestFilterTests",
    bazel_args = [
        "--test_output=all",
        "--test_filter=scalarules.test.*",
    ],
    expect = [
        "expected_test_filter_a.txt",
        "expected_test_filter_b.txt",
    ],
)

expect_test_success_test(
    name = "test_filter_single_test",
    target = "//test:TestFilterTests",
    bazel_args = [
        "--test_output=all",
        "--test_filter=scalarules.test.TestFilterTestA",
    ],
    expect = ["expected_test_filter_a.txt"],
    reject = ["expected_test_filter_b.txt"],
)
