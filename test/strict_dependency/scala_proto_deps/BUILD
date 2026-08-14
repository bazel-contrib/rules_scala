load("@rules_java//java:defs.bzl", "java_library")
load("@rules_proto//proto:defs.bzl", "proto_library")
load("//scala:scala.bzl", "scala_library")
load("//scala_proto:scala_proto.bzl", "scala_proto_library")
load("//scala_proto:scala_proto_toolchain.bzl", "scalapb_toolchain")
load(":customized_scala_proto.bzl", "custom_stamping_convention", "custom_stamping_scala_proto_library")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test")

proto_library(
    name = "some_proto",
    srcs = ["some.proto"],
)

scala_proto_library(
    name = "some_scala_proto",
    deps = [":some_proto"],
)

scala_library(
    name = "uses_transitive_scala_proto",
    srcs = ["UseScalaProtoIndirectly.scala"],
    # Missing a direct dep under strict deps even by default; the two tests
    # below build it under a strict-deps-error toolchain either way.
    tags = ["manual"],
    deps = [":transitive"],
)

# java library is used to prevent label collection and force looking into jar stamp
java_library(
    name = "transitive",
    srcs = ["UseTestMessage.java"],
    deps = [":some_scala_proto"],
)

scalapb_toolchain(
    name = "stamp_by_convention_toolchain_impl",
    stamp_by_convention = True,
)

toolchain(
    name = "stamp_by_convention_toolchain",
    toolchain = ":stamp_by_convention_toolchain_impl",
    toolchain_type = "//scala_proto:toolchain_type",
)

custom_stamping_convention(
    name = "phase_custom_stamping",
)

custom_stamping_scala_proto_library(
    name = "some_proto_custom_suffix",
    deps = [":some_proto"],
)

# java library is used to prevent label collection and force looking into jar stamp
java_library(
    name = "custom_transitive",
    srcs = ["UseTestMessage.java"],
    deps = [":some_proto_custom_suffix"],
)

scala_library(
    name = "uses_transitive_some_proto_custom_suffix",
    srcs = ["UseScalaProtoIndirectly.scala"],
    # Missing a direct dep under strict deps even by default; the test below
    # builds it under a strict-deps-error toolchain either way.
    tags = ["manual"],
    deps = [":custom_transitive"],
)

# The stamped labels below name a self-repo canonical target
# (@@//test/strict_dependency/scala_proto_deps:...); whether Bazel prints the
# leading "@@" varies across the Bazel-version matrix this suite runs under.
# The expected message starts right after where that "@@" would be, at the
# "//" the label itself starts with, so the match is unaffected either way.

expect_build_failure_test(
    name = "incorrect_proto_stamp_test",
    build_args = ["--extra_toolchains=//test/toolchains:ast_plus_one_deps_strict_deps_error"],
    expect = ["expected_incorrect_proto_stamp.txt"],
    target = ":uses_transitive_scala_proto",
)

expect_build_failure_test(
    name = "stamp_by_convention_test",
    build_args = ["--extra_toolchains=//test/toolchains:ast_plus_one_deps_strict_deps_error,//test/strict_dependency/scala_proto_deps:stamp_by_convention_toolchain"],
    expect = ["expected_stamp_by_convention.txt"],
    target = ":uses_transitive_scala_proto",
)

expect_build_failure_test(
    name = "custom_phase_stamping_test",
    build_args = ["--extra_toolchains=//test/toolchains:ast_plus_one_deps_strict_deps_error,//test/strict_dependency/scala_proto_deps:stamp_by_convention_toolchain"],
    expect = ["expected_custom_phase_stamping.txt"],
    target = ":uses_transitive_some_proto_custom_suffix",
)
