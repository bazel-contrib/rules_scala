load("//scala/private:bzl_library.bzl", "bzl_library")
load(
    "//twitter_scrooge/toolchain:toolchain.bzl",
    "DEP_PROVIDERS",
    "export_scrooge_deps",
)

[
    export_scrooge_deps(
        name = dep,
        deps_id = dep,
        visibility = ["//visibility:public"],
    )
    for dep in DEP_PROVIDERS
]

bzl_library(
    name = "twitter_scrooge",
    srcs = ["twitter_scrooge.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private:common",
        "//scala/private:dependency",
        "//scala/private:rule_impls",
        "//thrift:thrift",
        "//thrift:thrift_info",
        "@bazel_skylib//lib:dicts",
        "@rules_java//java/common:common",
    ],
)
