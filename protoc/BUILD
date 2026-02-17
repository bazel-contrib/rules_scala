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

# Note: The alias to @com_google_protobuf//bazel/toolchains:prefer_prebuilt_protoc
# was removed because it has visibility restrictions in Bzlmod mode.
# To use prebuilt protoc, set the flag directly when @com_google_protobuf is available:
#   --@com_google_protobuf//bazel/toolchains:prefer_prebuilt_protoc=true
