load("//scala:scala.bzl", "scala_test")
load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_test_failure_test")

scala_toolchain(
    name = "failing_toolchain_impl",
    # This will fail because :failing_jacocorunner is not a valid JacocoRunner.
    jacocorunner = ":failing_jacocorunner",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "failing_scala_toolchain",
    toolchain = "failing_toolchain_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

# A trivial test; under the failing toolchain above `bazel coverage` fails
# because the configured jacocorunner is invalid. Tagged "manual" so wildcard
# runs skip the fixture; the sh_test drives a nested `bazel coverage` with the
# failing toolchain and asserts the failure.
scala_test(
    name = "empty_test",
    srcs = ["EmptyTest.scala"],
    tags = ["manual"],
)

filegroup(
    name = "failing_jacocorunner",
    srcs = ["EmptyTest.scala"],
)

expect_test_failure_test(
    name = "scala_test_jacocorunner_from_toolchain_fails_test",
    # Jacoco coverage support is not implemented on Windows (mirrors the
    # is_windows guard in the former test/shell/test_scala_jacocorunner.sh).
    command = "coverage",
    bazel_args = ["--extra_toolchains=//test/toolchains/scala_test_jacocorunner:failing_scala_toolchain"],
    target = ":empty_test",
    target_compatible_with = select({
        "@platforms//os:windows": ["@platforms//:incompatible"],
        "//conditions:default": [],
    }),
)
