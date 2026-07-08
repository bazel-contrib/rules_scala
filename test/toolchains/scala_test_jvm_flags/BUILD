load("//scala:scala.bzl", "scala_test")
load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_test_failure_test")

scala_toolchain(
    name = "failing_toolchain_impl",
    # This will fail because 1M isn't enough heap to run the test JVM.
    scala_test_jvm_flags = ["-Xmx1M"],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "failing_scala_toolchain",
    toolchain = "failing_toolchain_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

# A trivial passing test; under the failing toolchain above its JVM can't start,
# so `bazel test` fails. Tagged "manual" so wildcard test runs skip the fixture
# (with the default toolchain it would just pass); the sh_test drives a nested
# `bazel test` with the failing toolchain and asserts the failure.
scala_test(
    name = "empty_test",
    srcs = ["EmptyTest.scala"],
    tags = ["manual"],
)

expect_test_failure_test(
    name = "scala_test_jvm_flags_from_toolchain_fails_test",
    bazel_args = ["--extra_toolchains=//test/toolchains/scala_test_jvm_flags:failing_scala_toolchain"],
    target = ":empty_test",
)
