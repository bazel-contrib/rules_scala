load("//scala:scala.bzl", "scala_library")
load("//scala:scala_cross_version_select.bzl", "select_for_scala_version")

scala_library(
    name = "source_compat",
    srcs = select_for_scala_version(
        before_3 = ["scala2/SourceCompat.scala"],
        since_3 = ["scala3/SourceCompat.scala"],
    ),
    visibility = [
        "//scala:__subpackages__",
        "//src:__subpackages__",
        "//third_party:__subpackages__",
    ],
)
