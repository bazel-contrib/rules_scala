load("//scala/private:bzl_library.bzl", "bzl_library")
load("//scala/settings:stamp_settings.bzl", "stamp_scala_import")

stamp_scala_import(
    name = "stamp_scala_import",
    build_setting_default = True,
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "stamp_settings",
    srcs = ["stamp_settings.bzl"],
    visibility = ["//visibility:public"],
)
