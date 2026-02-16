load(
    "@bazel_skylib//rules:common_settings.bzl",
    "bool_flag",
)
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

# Build setting to signal that rules_scala is using prebuilt protoc toolchains.
# This replaces the previous alias to @com_google_protobuf//bazel/toolchains:prefer_prebuilt_protoc
# which had visibility restrictions in Bzlmod.
# Users should set: --@rules_scala//protoc:prefer_prebuilt_protoc=true
# This is automatically set in rules_scala's .bazelrc.
bool_flag(
    name = "prefer_prebuilt_protoc",
    build_setting_default = False,
    visibility = ["//visibility:public"],
)

config_setting(
    name = "prefer_prebuilt_protoc_enabled",
    flag_values = {
        ":prefer_prebuilt_protoc": "true",
    },
    visibility = ["//visibility:public"],
)
