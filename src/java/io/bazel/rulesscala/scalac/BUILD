load("@rules_java//java:defs.bzl", "java_library", "java_test")
load("//scala:scala_cross_version_select.bzl", "select_for_scala_version")
load("//src/java/io/bazel/rulesscala/scalac:definitions.bzl", "define_scalac", "define_scalac_bootstrap")

define_scalac()

define_scalac_bootstrap()

filegroup(
    name = "scalac_files",
    srcs = [
        "ScalacInvokerResults.java",
        "ScalacWorker.java",
        "StdlibVersionCheck.java",
    ] + select_for_scala_version(
        any_2 = glob(["scala_2/*.java"]),
        any_3 = glob(["scala_3/*.java"]),
    ),
    visibility = ["//visibility:public"],
)

java_library(
    name = "stdlib_version_check",
    srcs = ["StdlibVersionCheck.java"],
    deps = ["//src/java/io/bazel/rulesscala/worker"],
)

java_test(
    name = "StdlibVersionCheckTest",
    srcs = ["StdlibVersionCheckTest.java"],
    test_class = "io.bazel.rulesscala.scalac.StdlibVersionCheckTest",
    deps = [":stdlib_version_check"],
)
