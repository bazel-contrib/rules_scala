# Migrated from test/shell/test_scala_proto_library.sh.

load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test")

package(default_testonly = 1)

expect_build_failure_test(
    name = "scala_proto_failing_generator",
    build_args = [
        "--extra_toolchains=//test/proto/custom_generator:failing_scala_proto_deps_toolchain",
        "--extra_toolchains=//test/proto/custom_generator:failing_scala_proto_toolchain",
    ],
    expect = ["expected_generator_failure.txt"],
    target = "//test/proto/custom_generator:any_proto_scala",
)
