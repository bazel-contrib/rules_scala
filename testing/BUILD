load("//scala/private:bzl_library.bzl", "bzl_library")
load("@rules_scala_config//:config.bzl", "SCALA_VERSION")
load("//scala:scala_cross_version.bzl", "version_suffix")

# Aliases for backward compatibility:
[
    alias(
        name = framework + "_toolchain",
        actual = (
            "@rules_scala_toolchains//testing:testing_toolchain" +
            version_suffix(SCALA_VERSION)
        ),
    )
    for framework in [
        "testing",
        "scalatest",
        "specs2_junit",
        "junit",
    ]
]

exports_files(["testing.bzl"])

bzl_library(
    name = "testing",
    srcs = ["testing.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//junit:junit",
        "//scala:providers",
        "//scala:scala_cross_version",
        "//scalatest:scalatest",
        "//specs2:specs2_bzl",
        "//specs2:specs2_junit",
        "//testing/toolchain:toolchain",
        "@rules_scala_config//:config",
    ],
)
