load("//scala/private:bzl_library.bzl", "bzl_library")
load(
    "//scala_proto/private:toolchain_deps.bzl",
    "export_scalapb_toolchain_deps",
)

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

toolchain_type(
    name = "deps_toolchain_type",
    visibility = ["//visibility:public"],
)

export_scalapb_toolchain_deps(
    name = "scalapb_worker_deps",
    deps_id = "scalapb_worker_deps",
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "scala_proto",
    srcs = ["scala_proto.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//scala_proto/private:scala_proto",
        "//scala_proto/private:scala_proto_aspect",
    ],
)

bzl_library(
    name = "scala_proto_toolchain",
    srcs = ["scala_proto_toolchain.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//protoc:private/toolchain_impl",
        "//scala:providers",
        "//scala_proto/default:default_deps",
        "@rules_java//java/common:common",
    ],
)

bzl_library(
    name = "toolchains",
    srcs = ["toolchains.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        ":scala_proto_toolchain",
    ],
)
