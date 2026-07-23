load("//scala:scala.bzl", "scala_library")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test")

package(default_testonly = 1)

# `resource_strip_prefix` does not match the resource's path, so this library is
# expected to fail to build. Tagged "manual" so wildcard builds skip it.
scala_library(
    name = "noSrcsJarWithWrongStripPrefix",
    resource_strip_prefix = "wrong_prefix",
    resources = ["resource.txt"],
    tags = ["manual"],
)

expect_build_failure_test(
    name = "mismatching_resource_strip_prefix",
    expect = ["expected_mismatching_prefix.txt"],
    target = ":noSrcsJarWithWrongStripPrefix",
)
