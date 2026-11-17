load("//scala/private:bzl_library.bzl", "bzl_library")
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

# Aliases the @protobuf >= v33.4 flag so test modules -- which see @rules_scala
# but not @com_google_protobuf -- can toggle it via
# `--@rules_scala//protoc:prefer_prebuilt_protoc` (e.g. from a copied .bazelrc).
#
# Tagged "manual" because in @protobuf 33.5 the underlying flag became
# package-private, so analyzing this alias as a build target (e.g. under
# `bazel build //...`) fails a visibility check. Setting it as a --flag does not
# require that visibility, so the alias still serves its purpose; the tag just
# keeps it out of wildcard builds.
alias(
    name = "prefer_prebuilt_protoc",
    actual = "@com_google_protobuf//bazel/toolchains:prefer_prebuilt_protoc",
    tags = ["manual"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "private/protoc_integrity",
    srcs = ["private/protoc_integrity.bzl"],
    visibility = ["//:__subpackages__"],
)

bzl_library(
    name = "private/protoc_toolchains",
    # protobuf_version.bzl is visible only inside @com_google_protobuf.
    extract_docs = False,
    srcs = ["private/protoc_toolchains.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        ":private/protoc_integrity",
        ":private/toolchain_impl",
        "@platforms//host:constraints_lib",
    ],
)

bzl_library(
    name = "private/toolchain_impl",
    srcs = ["private/toolchain_impl.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "@com_google_protobuf//bazel/common:proto_common_bzl",
    ],
)

bzl_library(
    name = "toolchains",
    # protobuf_version.bzl is visible only inside @com_google_protobuf.
    extract_docs = False,
    srcs = ["toolchains.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        ":private/protoc_toolchains",
    ],
)
