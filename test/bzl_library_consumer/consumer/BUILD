load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

bzl_library(
    name = "macros",
    srcs = ["macros.bzl"],
    deps = [
        "@rules_scala//scala",
        "@rules_scala//scala:advanced_usage/scala",
    ],
)

starlark_doc_extract(
    name = "macros_doc",
    src = "macros.bzl",
    deps = [":macros"],
)
