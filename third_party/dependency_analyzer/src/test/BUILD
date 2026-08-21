load("//scala:scala.bzl", "scala_test")
load(":analyzer_test.bzl", "tests", "version_specific_tests")

tests()

version_specific_tests()

scala_test(
    name = "test_optionsparser",
    srcs = ["test_optionsparser.scala"],
    deps = ["//third_party/dependency_analyzer/src/main:dependency_analyzer"],
)

filegroup(
    name = "package_sources",
    srcs = glob(["**/*"], allow_empty = True),
    visibility = ["//test/community_build:__pkg__"],
)
