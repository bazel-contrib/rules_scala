load("//scala:scala.bzl", "scala_test")
load("//scala:scala_toolchain.bzl", "scala_toolchain")
load(
    "//test/expect_build_failure:expect_build_failure.bzl",
    "expect_test_failure_test",
    "expect_test_success_test",
)

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

scala_toolchain(
    name = "passing_toolchain_impl",
    # 1G is enough heap to run the test JVM.
    scala_test_jvm_flags = ["-Xmx1G"],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "passing_scala_toolchain",
    toolchain = "passing_toolchain_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

# A trivial passing test; under `failing_scala_toolchain` its JVM can't start, so
# `bazel test` fails. Tagged "manual" so wildcard test runs skip the fixture (it
# passes under the default toolchain too); the two tests below drive a nested
# `bazel test` with `failing_scala_toolchain` and `passing_scala_toolchain`
# respectively.
scala_test(
    name = "empty_test",
    srcs = ["EmptyTest.scala"],
    tags = ["manual"],
)

# Rule-level `jvm_flags` overrides the toolchain's, so this passes even under
# `failing_scala_toolchain`.
scala_test(
    name = "empty_overriding_test",
    srcs = ["EmptyTest.scala"],
    jvm_flags = ["-Xmx1G"],
    tags = ["manual"],
)

_FAILING = "--extra_toolchains=//test/toolchains/scala_test_jvm_flags:failing_scala_toolchain"

_PASSING = "--extra_toolchains=//test/toolchains/scala_test_jvm_flags:passing_scala_toolchain"

expect_test_failure_test(
    name = "scala_test_jvm_flags_from_toolchain_fails_test",
    bazel_args = [
        _FAILING,
        "--test_output=errors",
    ],
    expect = ["expected_too_small_heap.txt"],
    target = ":empty_test",
)

expect_test_success_test(
    name = "scala_test_jvm_flags_from_toolchain_passes_test",
    bazel_args = [_PASSING],
    target = ":empty_test",
)

expect_test_success_test(
    name = "scala_test_jvm_flags_on_target_overrides_toolchain_test",
    bazel_args = [_FAILING],
    target = ":empty_overriding_test",
)
