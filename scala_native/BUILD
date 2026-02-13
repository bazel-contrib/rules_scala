package(default_visibility = ["//visibility:public"])

exports_files(["*.bzl"])

# Scala Native toolchain type
toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

load(":scala_native_toolchain.bzl", "scala_native_toolchain")

toolchain(
    name = "scala_native_toolchain",
    toolchain = ":default_scala_native_toolchain",
    toolchain_type = ":toolchain_type",
    visibility = ["//visibility:public"],
)
