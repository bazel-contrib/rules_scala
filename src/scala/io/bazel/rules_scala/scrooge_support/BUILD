load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "compiler",
    srcs = [
        "Compiler.scala",
        "FocusedZipImporter.scala",
    ],
    # util_core is still needed as a dep for older versions of scrooge
    unused_dependency_checker_mode = "off",
    visibility = ["//visibility:public"],
    deps = [
        "//twitter_scrooge:compiler_classpath",
    ],
)

filegroup(
    name = "package_sources",
    srcs = glob(["**/*"], allow_empty = True),
    visibility = ["//test/community_build:__pkg__"],
)
