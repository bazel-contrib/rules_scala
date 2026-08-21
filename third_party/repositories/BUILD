# For //test/scala_config:scalac_javac_uses_scala_library_*_test, which assert the
# scala-library coordinate these files pin lands on the scalac classpath; listing
# them in those tests' `data` re-keys the tests when a coordinate is bumped.
exports_files([
    "scala_2_12.bzl",
    "scala_2_13.bzl",
])

filegroup(
    name = "package_sources",
    srcs = glob(["**/*"], allow_empty = True),
    visibility = ["//test/community_build:__pkg__"],
)
