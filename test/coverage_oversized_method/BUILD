load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("//scala:scala.bzl", "scala_library", "scala_test")
load(":oversized_method.bzl", "oversized_method_source")

write_file(
    name = "oversized_method_source",
    out = "OversizedMethod.scala",
    content = oversized_method_source(),
)

scala_library(
    name = "oversized_method",
    srcs = ["OversizedMethod.scala"],
)

scala_library(
    name = "small_class",
    srcs = ["SmallClass.scala"],
)

scala_test(
    name = "test-oversized-method",
    srcs = ["TestOversizedMethod.scala"],
    tags = ["manual"],
    deps = [
        ":oversized_method",
        ":small_class",
    ],
)
