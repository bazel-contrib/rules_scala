load("//jmh/toolchain:toolchain.bzl", "DEP_PROVIDERS", "export_toolchain_deps")
load("//scala/private:bzl_library.bzl", "bzl_libraries")

[
    export_toolchain_deps(
        name = provider,
        deps_id = provider,
        visibility = ["//visibility:public"],
    )
    for provider in DEP_PROVIDERS
]

bzl_libraries()
