load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "test_discovery",
    srcs = [
        "ArchiveEntries.scala",
        "DiscoveredTestSuite.scala",
        "FilteredRunnerBuilder.scala",
    ],
    visibility = ["//visibility:public"],
    exports = ["//scala/private/source_compat"],
    deps = [
        "//scala/private/source_compat",
        "//testing/toolchain:junit_classpath",
    ],
)
