load("//jmh:jmh.bzl", "scala_benchmark_jmh")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test")

# Migrated from test/shell/test_misc.sh (test_benchmark_jmh_failure).
#
# A JMH benchmark class may not be `final`, so this target is expected to fail to
# build. It is tagged "manual" so wildcard `bazel build //...` skips it; the
# expect_build_failure_test drives a nested `bazel build` and asserts the failure.
#
# This lives in its own package rather than //test/jmh so that //test/jmh does
# not load @rules_shell (a dev-only dependency, invisible when rules_scala is
# consumed as a module): //test/jmh:jmh_command_line_parsing_test is built by
# test_dependency_versions.sh as an external-module consumer.
scala_benchmark_jmh(
    name = "jmh_reports_failure",
    srcs = ["InvalidBenchmark.scala"],
    tags = ["manual"],
)

expect_build_failure_test(
    name = "jmh_reports_failure_build_test",
    target = "//test/jmh/reports_failure:jmh_reports_failure",
)
