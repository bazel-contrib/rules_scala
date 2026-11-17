load("//scala/private:bzl_library.bzl", "bzl_library")
load("//testing:testing.bzl", "DEP_PROVIDERS")
load(":toolchain_deps.bzl", "testing_toolchain_deps")

toolchain_type(
    name = "testing_toolchain_type",
    visibility = ["//visibility:public"],
)

[
    testing_toolchain_deps(
        name = dep,
        deps_id = dep,
        visibility = ["//visibility:public"],
    )
    for dep in DEP_PROVIDERS
]

bzl_library(
    name = "toolchain",
    srcs = ["toolchain.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//scala:providers",
    ],
)

bzl_library(
    name = "toolchain_deps",
    srcs = ["toolchain_deps.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private/toolchain_deps:toolchain_deps",
    ],
)
