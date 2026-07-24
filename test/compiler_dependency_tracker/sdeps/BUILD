load("//scala:scala.bzl", "scala_library", "scala_specs2_junit_test")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_test_success_test")

scala_library(
    name = "only_scala_sources",
    srcs = [
        "SomeScalaWithDeps.scala",
    ],
    unused_dependency_checker_ignored_targets = [
        ":scala_ignored_unused_dep",
    ],
    deps = [
        ":scala_dep",
        ":scala_ignored_unused_dep",
        ":scala_unused_dep",
    ],
)

scala_library(
    name = "mixed_sources",
    srcs = [
        "SomeJava.java",
        "SomeScalaWithDeps.scala",
    ],
    unused_dependency_checker_ignored_targets = [
        ":scala_ignored_unused_dep",
    ],
    deps = [
        ":scala_dep",
        ":scala_ignored_unused_dep",
        ":scala_unused_dep",
    ],
)

scala_library(
    name = "scala_dep",
    srcs = ["ScalaDep.scala"],
)

scala_library(
    name = "scala_unused_dep",
    srcs = ["AnotherScalaDep.scala"],
)

scala_library(
    name = "scala_ignored_unused_dep",
    srcs = ["IgnoredScalaDep.scala"],
)

# The `.sdeps` resources are only emitted by an ast-plus toolchain, so this test
# passes only under ast_plus_warn. Tagged "manual" so a wildcard `bazel test`
# skips it; run explicitly (with the toolchain) by the :sdeps target below.
scala_specs2_junit_test(
    name = "sdeps_test",
    srcs = ["SdepsTest.scala"],
    resources = [
        ":mixed_sources.sdeps",
        ":only_scala_sources.sdeps",
    ],
    suffixes = ["Test"],
    tags = ["manual"],
    deps = [
        "//src/java/io/bazel/rulesscala/scalac/reporter:scala_deps_java_proto",
        "@com_google_protobuf//:protobuf_java",
    ],
)

expect_test_success_test(
    name = "sdeps",
    bazel_args = ["--extra_toolchains=//test/compiler_dependency_tracker:ast_plus_warn"],
    target = ":sdeps_test",
)
