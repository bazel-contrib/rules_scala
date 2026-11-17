load("//scala/private:bzl_library.bzl", "bzl_library")


bzl_library(
    name = "default_deps",
    srcs = ["default_deps.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//scala:scala_cross_version",
        "@rules_scala_config//:config",
    ],
)

bzl_library(
    name = "repositories",
    srcs = ["repositories.bzl"],
    visibility = ["//visibility:public"],
)
