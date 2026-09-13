load("@bazel_skylib//rules:write_file.bzl", "write_file")
load("//scala:scala.bzl", "scala_library", "scala_test")
load("//test/coverage_test:coverage_test.bzl", "coverage_test")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_test_failure_test", "expect_test_success_test")
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

expect_test_success_test(
    name = "oversized_method_passes_without_coverage_test",
    command = "test",
    target = ":test-oversized-method",
)

expect_test_failure_test(
    name = "oversized_method_fails_coverage_by_default_test",
    command = "coverage",
    target = ":test-oversized-method",
    expect = ["expected_method_too_large_message.txt"],
)

coverage_test(
    name = "oversized_method_skipped_when_enabled_test",
    target = ":test-oversized-method",
    bazel_args = ["--extra_toolchains=//test/toolchains:coverage_skip_oversized_methods"],
    expected_output = "JacocoInstrumenter: skipping",
    expected_line = "SF:test/coverage_oversized_method/SmallClass.scala",
    reject_line = "OversizedMethod",
)
