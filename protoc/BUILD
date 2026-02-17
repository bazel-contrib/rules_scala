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

# Build setting to maintain backward compatibility with the previous alias.
# This flag no longer has any effect since the alias to @com_google_protobuf
# was removed due to Bzlmod visibility restrictions.
# Kept for backward compatibility with existing .bazelrc files.
bool_flag(
    name = "prefer_prebuilt_protoc",
    build_setting_default = False,
    visibility = ["//visibility:public"],
)
