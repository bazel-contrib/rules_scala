load("//scala/private:bzl_library.bzl", "bzl_library")
toolchain_type(
    name = "scalafmt_toolchain_type",
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "setup_scalafmt_toolchain",
    srcs = ["setup_scalafmt_toolchain.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//scala/scalafmt:scalafmt_repositories",
        "//scala:providers",
        "//scala:scala_cross_version",
        ":toolchain",
        "@rules_scala_config//:config",
    ],
)

bzl_library(
    name = "toolchain",
    srcs = ["toolchain.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private/toolchain_deps:toolchain_deps",
        "//scala:providers",
    ],
)
