load("//scala/private:bzl_library.bzl", "bzl_library")
load(":toolchain_dep_rules.bzl", "common_toolchain_deps")

common_toolchain_deps(
    name = "scala_compile_classpath",
    deps_id = "scala_compile_classpath",
    visibility = ["//visibility:public"],
)

common_toolchain_deps(
    name = "scala_library_classpath",
    deps_id = "scala_library_classpath",
    visibility = ["//visibility:public"],
)

common_toolchain_deps(
    name = "scala_xml",
    deps_id = "scala_xml",
    visibility = ["//visibility:public"],
)

common_toolchain_deps(
    name = "parser_combinators",
    deps_id = "parser_combinators",
    visibility = ["//visibility:public"],
)

common_toolchain_deps(
    name = "semanticdb",
    deps_id = "semanticdb",
    visibility = ["//visibility:public"],
)

common_toolchain_deps(
    name = "scala_doc_classpath",
    deps_id = "scala_doc_classpath",
    optional = True,
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "toolchain_dep_rules",
    srcs = ["toolchain_dep_rules.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        ":toolchain_deps",
    ],
)

bzl_library(
    name = "toolchain_deps",
    srcs = ["toolchain_deps.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//scala:providers",
        "@rules_java//java/common:common",
    ],
)
