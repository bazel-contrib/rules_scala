load("@rules_java//java:defs.bzl", "java_library")

java_library(
    name = "runner",
    srcs = ["Runner.java"],
    visibility = ["//visibility:public"],
    deps = [
        "//testing/toolchain:scalatest_classpath",
        "@bazel_tools//tools/java/runfiles",
    ],
)

filegroup(
    name = "package_sources",
    srcs = glob(["**/*"], allow_empty = True),
    visibility = ["//test/community_build:__pkg__"],
)
