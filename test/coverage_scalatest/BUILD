load("@rules_java//java:defs.bzl", "java_library", "java_test")
load("//scala:scala.bzl", "scala_library", "scala_test")
load("//test/coverage_test:coverage_test.bzl", "coverage_test")

coverage_test(
    name = "coverage_matches_expected_test",
    # Default to 2.12.21 because other Scala versions change the output.
    bazel_args = ["--repo_env=SCALA_VERSION=2.12.21"],
    expected = "test/coverage_scalatest/expected-coverage.dat",
    target = ":test-scalatest",
)

coverage_test(
    name = "coverage_includes_test_targets_test",
    bazel_args = ["--instrument_test_targets=True"],
    grep = "SF:test/coverage_scalatest/TestWithScalaTest.scala",
    target = ":test-scalatest",
)

scala_test(
    name = "test-scalatest",
    srcs = [
        "TestWithScalaTest.scala",
    ],
    deps = [
        ":a1",
        ":a2",
        ":b1",
        ":d1",
    ],
)

java_test(
    name = "test-b2",
    srcs = [
        "TestB2.java",
    ],
    tags = ["manual"],
    test_class = "coverage.TestB2",
    deps = [
        ":b2",
    ],
)

scala_library(
    name = "a1",
    srcs = [
        "A1.scala",
    ],
    deps = [
        ":b1",
    ],
)

scala_library(
    name = "b1",
    srcs = [
        "B1.scala",
    ],
)

scala_library(
    name = "a2",
    srcs = [
        "A2.scala",
    ],
    deps = [
        ":b2",
    ],
)

java_library(
    name = "b2",
    srcs = [
        "B2.java",
    ],
    deps = [
        ":c2",
    ],
)

scala_library(
    name = "c2",
    srcs = [
        "C2.scala",
    ],
)

scala_library(
    name = "d1",
    srcs = [
        "D1.scala",
    ],
)
