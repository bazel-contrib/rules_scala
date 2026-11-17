load("//scala/private:bzl_library.bzl", "bzl_library")


bzl_library(
    name = "scala_proto",
    srcs = ["scala_proto.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//scala/private:phases/api",
        ":scala_proto_aspect",
        ":scala_proto_aspect_provider",
        "@bazel_skylib//lib:dicts",
        "@com_google_protobuf//bazel/common:proto_info_bzl",
        "@rules_java//java/common:common",
    ],
)

bzl_library(
    name = "scala_proto_aspect",
    srcs = ["scala_proto_aspect.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//scala/private/toolchain_deps:toolchain_deps",
        "//scala/private:common",
        "//scala/private:dependency",
        "//scala/private:phases/api",
        "//scala/private:rule_impls",
        ":scala_proto_aspect_provider",
        "@bazel_skylib//lib:dicts",
        "@com_google_protobuf//bazel/common:proto_info_bzl",
        "@rules_java//java/common:common",
    ],
)

bzl_library(
    name = "scala_proto_aspect_provider",
    srcs = ["scala_proto_aspect_provider.bzl"],
    visibility = ["//:__subpackages__"],
)

bzl_library(
    name = "toolchain_deps",
    srcs = ["toolchain_deps.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//scala/private/toolchain_deps:toolchain_deps",
    ],
)
