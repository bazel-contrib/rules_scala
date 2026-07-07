load("//scala:scala.bzl", "scala_library")
load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test")

# Migrated from test/shell/test_scalac_jvm_flags.sh
# (test_scalac_jvm_flags_from_scala_toolchain_fails).
#
# `failing_scala_toolchain` sets scalac_jvm_flags = ["-Xmx1M"], which is not
# enough heap for scalac, so `empty_build` fails to compile when that toolchain
# is registered. `empty_build` compiles fine under the default toolchain, so it
# is tagged "manual" to keep it out of wildcard builds; the sh_test registers
# the failing toolchain via --extra_toolchains in a nested `bazel build`.

scala_toolchain(
    name = "failing_toolchain_impl",
    scalac_jvm_flags = ["-Xmx1M"],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "failing_scala_toolchain",
    toolchain = "failing_toolchain_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_library(
    name = "empty_build",
    srcs = ["Empty.scala"],
    tags = ["manual"],
)

expect_build_failure_test(
    name = "scalac_jvm_flags_from_toolchain_fails_build_test",
    build_args = ["--extra_toolchains=//test/toolchains/scalac_jvm_opts:failing_scala_toolchain"],
    target = "//test/toolchains/scalac_jvm_opts:empty_build",
)
