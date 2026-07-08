load("//scala:scala.bzl", "scala_library")
load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test")

# `failing_scala_toolchain` adds scalacopts = ["-Ywarn-unused"]; combined with
# the target's own -Xfatal-warnings, the unused val in ClassWithUnused.scala
# becomes a fatal warning, so `failing_build` fails to compile when that
# toolchain is registered. Under the default toolchain there is no unused
# warning, so the target is tagged "manual" to keep it out of wildcard builds;
# the sh_test registers the failing toolchain via --extra_toolchains.

scala_toolchain(
    name = "failing_toolchain_impl",
    scalacopts = ["-Ywarn-unused"],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "failing_scala_toolchain",
    toolchain = "failing_toolchain_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_library(
    name = "failing_build",
    srcs = ["ClassWithUnused.scala"],
    scalacopts = ["-Xfatal-warnings"],
    tags = ["manual"],
)

expect_build_failure_test(
    name = "scalacopts_from_toolchain_fails_build_test",
    build_args = ["--extra_toolchains=//test/scalacopts/scalacopts_from_toolchain:failing_scala_toolchain"],
    target = ":failing_build",
)
