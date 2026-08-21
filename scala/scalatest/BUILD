package(default_visibility = ["//visibility:public"])

alias(
    name = "scalatest",
    actual = "//testing/toolchain:scalatest_classpath",
    deprecation = "Use //testing/toolchain:scalatest_classpath directly",
)

filegroup(
    name = "package_sources",
    srcs = glob(["**/*"], allow_empty = True),
    visibility = ["//test/community_build:__pkg__"],
)
