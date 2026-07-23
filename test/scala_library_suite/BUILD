load("//scala:scala.bzl", "scala_library_suite")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test")

# A scala_library_suite whose children depend on one another must be rejected.
# Tagged "manual" so wildcard builds skip it; the sh_test drives a nested
# `bazel build` and asserts the failure.
scala_library_suite(
    name = "library_suite_dep_on_children",
    srcs = glob(["Data*.scala"]),
    tags = ["manual"],
)

expect_build_failure_test(
    name = "scala_library_suite_build_test",
    target = ":library_suite_dep_on_children",
)
