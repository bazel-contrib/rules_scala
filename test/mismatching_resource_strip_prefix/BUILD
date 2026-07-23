load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test")

package(default_testonly = 1)

expect_build_failure_test(
    name = "mismatching_resource_strip_prefix",
    expect = ["expected_mismatching_prefix.txt"],
    target = "//test_expect_failure/mismatching_resource_strip_prefix:noSrcsJarWithWrongStripPrefix",
)
