load("@rules_java//java:defs.bzl", "java_library")

java_library(
    name = "io_utils",
    srcs = glob(["*.java"]),
    visibility = ["//visibility:public"],
)

filegroup(
    name = "package_sources",
    srcs = glob(["**/*"], allow_empty = True),
    visibility = ["//test/community_build:__pkg__"],
)
