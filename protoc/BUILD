load(
    "@com_google_protobuf//bazel/toolchains:proto_lang_toolchain.bzl",
    "proto_lang_toolchain",
)

exports_files(
    ["toolchains.bzl"],
    visibility = ["//visibility:public"],
)

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

proto_lang_toolchain(
    name = "scala_protoc_toolchain",
    command_line = "unused-because-we-pass-protoc-to-scalapb",
    toolchain_type = ":toolchain_type",
    visibility = ["//visibility:public"],
)

# Aliases the @protobuf >= v33.4 flag so test modules don't have to import
# @protobuf directly to handle the flag imported from .bazelrc.
alias(
    name = "prefer_prebuilt_protoc",
    actual = "@com_google_protobuf//bazel/toolchains:prefer_prebuilt_protoc",
    visibility = ["//visibility:public"],
)
