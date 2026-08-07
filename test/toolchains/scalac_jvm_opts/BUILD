load("@rules_proto//proto:defs.bzl", "proto_library")
load("//scala:scala.bzl", "scala_library")
load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//scala_proto:scala_proto.bzl", "scala_proto_library")
load(
    "//test/expect_build_failure:expect_build_failure.bzl",
    "expect_build_failure_test",
    "expect_build_success_test",
)

scala_toolchain(
    name = "failing_toolchain_impl",
    # 1M is not enough heap for scalac.
    scalac_jvm_flags = ["-Xmx1M"],
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
    # 1G is enough heap for scalac.
    scalac_jvm_flags = ["-Xmx1G"],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "passing_scala_toolchain",
    toolchain = "passing_toolchain_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

# `failing_scala_toolchain` sets scalac_jvm_flags = ["-Xmx1M"], which is not
# enough heap for scalac, so `empty_build` fails to compile when that toolchain
# is registered. `empty_build` compiles fine under the default toolchain, so it
# is tagged "manual" to keep it out of wildcard builds; the sh_test registers
# the failing toolchain via --extra_toolchains in a nested `bazel build`.
scala_library(
    name = "empty_build",
    srcs = ["Empty.scala"],
    tags = ["manual"],
)

# Rule-level `scalac_jvm_flags` overrides the toolchain's, so this compiles even
# under `failing_scala_toolchain`.
scala_library(
    name = "empty_overriding_build",
    srcs = ["Empty.scala"],
    scalac_jvm_flags = ["-Xmx1G"],
    tags = ["manual"],
)

proto_library(
    name = "test",
    srcs = ["test.proto"],
    tags = ["manual"],
)

# Regression test for a bug that broke compiling scalapb targets when
# `scalac_jvm_flags` was set on the toolchain.
scala_proto_library(
    name = "proto",
    tags = ["manual"],
    deps = [":test"],
)

_FAILING = "--extra_toolchains=//test/toolchains/scalac_jvm_opts:failing_scala_toolchain"

_PASSING = "--extra_toolchains=//test/toolchains/scalac_jvm_opts:passing_scala_toolchain"

expect_build_failure_test(
    name = "scalac_jvm_flags_from_toolchain_fails_build_test",
    build_args = [_FAILING],
    target = ":empty_build",
)

expect_build_success_test(
    name = "scalac_jvm_flags_from_toolchain_passes_build_test",
    build_args = [_PASSING],
    target = ":empty_build",
)

expect_build_success_test(
    name = "scalac_jvm_flags_on_target_overrides_toolchain_build_test",
    build_args = [_FAILING],
    target = ":empty_overriding_build",
)

expect_build_success_test(
    name = "scalac_jvm_flags_with_scalapb_build_test",
    build_args = [_PASSING],
    target = ":proto",
)
