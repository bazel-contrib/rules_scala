load("//scala/settings:stamp_settings.bzl", "stamp_scala_import")

stamp_scala_import(
    name = "stamp_scala_import",
    build_setting_default = True,
    visibility = ["//visibility:public"],
)

filegroup(
    name = "package_sources",
    srcs = glob(["**/*"], allow_empty = True),
    visibility = ["//test/community_build:__pkg__"],
)
