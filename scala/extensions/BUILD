load("//scala/private:bzl_library.bzl", "bzl_library")

exports_files(["config.bzl"])

bzl_library(
    name = "config",
    srcs = ["config.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//:scala_config",
        "//scala/private:macros/bzlmod",
    ],
)

bzl_library(
    name = "deps",
    srcs = ["deps.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private:macros/bzlmod",
        "//scala/private:toolchain_defaults",
        "//scala:scala_cross_version",
        "//scala:toolchains",
    ],
)

bzl_library(
    name = "protoc",
    # protobuf_version.bzl is visible only inside @com_google_protobuf.
    extract_docs = False,
    srcs = ["protoc.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//protoc:private/protoc_toolchains",
        "//scala/private:macros/bzlmod",
    ],
)
