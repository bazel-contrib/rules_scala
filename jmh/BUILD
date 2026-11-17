load("//scala/private:bzl_library.bzl", "bzl_library")
load("//jmh/toolchain:toolchain.bzl", "DEP_PROVIDERS", "export_toolchain_deps")

[
    export_toolchain_deps(
        name = provider,
        deps_id = provider,
        visibility = ["//visibility:public"],
    )
    for provider in DEP_PROVIDERS
]

bzl_library(
    name = "jmh",
    srcs = ["jmh.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private:rules/scala_binary",
        "//scala/private:rules/scala_library",
        "@rules_java//java/common:common",
    ],
)
