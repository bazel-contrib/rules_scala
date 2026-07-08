load("//scala:scala.bzl", "scala_library")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test")

scala_library(
    name = "a",
    srcs = ["A.scala"],
)

scala_library(
    name = "b",
    exports = [":a"],
)

scala_library(
    name = "c",
    deps = [":b"],
)

# `d` uses a type that is only reachable transitively (through `c` -> `b` ->
# exported `a`); strict deps must reject building it. Tagged "manual" so wildcard
# builds skip it; the sh_test drives a nested `bazel build` and asserts the failure.
scala_library(
    name = "d",
    srcs = ["D.scala"],
    tags = ["manual"],
    deps = [":c"],
)

expect_build_failure_test(
    name = "transitive_scala_to_scala_build_test",
    target = ":d",
)
