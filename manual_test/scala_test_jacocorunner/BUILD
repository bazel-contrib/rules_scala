load("//scala:scala.bzl", "scala_test")
load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_test_success_test")

scala_toolchain(
    name = "passing_toolchain_impl",
    jacocorunner = "@bazel_tools//tools/jdk:JacocoCoverage",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "passing_scala_toolchain",
    toolchain = "passing_toolchain_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_test(
    name = "empty_test",
    srcs = ["EmptyTest.scala"],
)

# Jacoco coverage support is not implemented on Windows (mirrors the
# is_windows guard in the former test/shell/test_scala_jacocorunner.sh).
expect_test_success_test(
    name = "scala_test_jacocorunner_from_scala_toolchain_passes_test",
    command = "coverage",
    bazel_args = ["--extra_toolchains=//manual_test/scala_test_jacocorunner:passing_scala_toolchain"],
    target = ":empty_test",
    target_compatible_with = select({
        "@platforms//os:windows": ["@platforms//:incompatible"],
        "//conditions:default": [],
    }),
)
