load("@rules_java//java:defs.bzl", "java_library")
load("//scala:scala.bzl", "scala_library")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test")

scala_library(
    name = "a",
    srcs = ["A.scala"],
)

java_library(
    name = "c",
    srcs = ["C.java"],
    deps = [":a"],
)

# `d` uses a Scala type reachable only transitively (through `c`); strict deps
# must reject building it with the "indirect dependency" error. Tagged "manual"
# so wildcard builds skip it; the sh_test drives a nested `bazel build`.
java_library(
    name = "d",
    srcs = ["D.java"],
    tags = ["manual"],
    deps = [":c"],
)

expect_build_failure_test(
    name = "transitive_java_to_scala_build_test",
    expect = ["expected_indirect_dependency.txt"],
    target = ":d",
)
