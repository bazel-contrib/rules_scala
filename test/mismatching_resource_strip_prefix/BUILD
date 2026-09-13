load("//scala:scala.bzl", "scala_library")
load("//test/expect_build_failure:expect_analysis_failure.bzl", "expect_analysis_failure_test")

package(default_testonly = 1)

# `resource_strip_prefix` does not match the resource's path, so this library is
# expected to fail to build. Tagged "manual" so wildcard builds skip it.
scala_library(
    name = "noSrcsJarWithWrongStripPrefix",
    resource_strip_prefix = "wrong_prefix",
    resources = ["resource.txt"],
    tags = ["manual"],
)

expect_analysis_failure_test(
    name = "mismatching_resource_strip_prefix",
    message = "Resource file test/mismatching_resource_strip_prefix/resource.txt is not under the specified prefix wrong_prefix to strip",
    target_under_test = ":noSrcsJarWithWrongStripPrefix",
)

# Same mismatch, but for a generated resource from an external repo.
expect_analysis_failure_test(
    name = "mismatching_resource_strip_prefix_external_generated",
    message = "Resource file strip/nosrc_jar_generated_resource.txt is not under the specified prefix wrong_prefix to strip",
    target_under_test = "@example_external_workspace//strip:noSrcsWithGeneratedResourceWrongPrefix",
)
