load("//scala/private:bzl_library.bzl", "bzl_library")
toolchain_type(
    name = "jmh_toolchain_type",
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "toolchain",
    srcs = ["toolchain.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private/toolchain_deps:toolchain_deps",
        "//scala:providers",
        "//scala:scala_cross_version",
        "@rules_scala_config//:config",
    ],
)
