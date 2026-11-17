load("//scala/private:bzl_library.bzl", "bzl_library")
# For //test/scala_config:scalac_javac_uses_scala_library_*_test, which assert the
# scala-library coordinate these files pin lands on the scalac classpath; listing
# them in those tests' `data` re-keys the tests when a coordinate is bumped.
exports_files([
    "scala_2_12.bzl",
    "scala_2_13.bzl",
])

# For //test/compiler_sources_integrity_test:latest_version_*_no_warning_test,
# which build under each of these files' pinned scala_version; listing them in
# those tests' `data` re-keys the tests when a version is bumped.
exports_files([
    "scala_3_1.bzl",
    "scala_3_2.bzl",
    "scala_3_3.bzl",
    "scala_3_4.bzl",
    "scala_3_5.bzl",
    "scala_3_6.bzl",
    "scala_3_7.bzl",
    "scala_3_8.bzl",
    "scala_3_9.bzl",
    "scala_3_10.bzl",
])

exports_files(
    ["repositories.bzl"],
    visibility = ["//test/scala_config:__pkg__"],
)

bzl_library(
    name = "repositories",
    srcs = ["repositories.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//scala:scala_cross_version",
        "//scala:scala_maven_import_external",
        ":scala_2_12",
        ":scala_2_13",
        ":scala_3_1",
        ":scala_3_10",
        ":scala_3_2",
        ":scala_3_3",
        ":scala_3_4",
        ":scala_3_5",
        ":scala_3_6",
        ":scala_3_7",
        ":scala_3_8",
        ":scala_3_9",
        "@rules_scala_config//:config",
    ],
)

bzl_library(
    name = "scala_2_12",
    srcs = ["scala_2_12.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "scala_2_13",
    srcs = ["scala_2_13.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "scala_3_1",
    srcs = ["scala_3_1.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "scala_3_10",
    srcs = ["scala_3_10.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "scala_3_2",
    srcs = ["scala_3_2.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "scala_3_3",
    srcs = ["scala_3_3.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "scala_3_4",
    srcs = ["scala_3_4.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "scala_3_5",
    srcs = ["scala_3_5.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "scala_3_6",
    srcs = ["scala_3_6.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "scala_3_7",
    srcs = ["scala_3_7.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "scala_3_8",
    srcs = ["scala_3_8.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "scala_3_9",
    srcs = ["scala_3_9.bzl"],
    visibility = ["//visibility:public"],
)
