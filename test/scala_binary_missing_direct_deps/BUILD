load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test")

_MISSING_DIRECT_DEPS_TOOLCHAIN = "--extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_error"

expect_build_failure_test(
    name = "user_binary_missing_direct_deps_test",
    build_args = [_MISSING_DIRECT_DEPS_TOOLCHAIN],
    expect = ["expected_user_binary_buildozer_message.txt"],
    target = "//test/missing_direct_deps/internal_deps:user_binary",
)

expect_build_failure_test(
    name = "binary_user_of_binary_missing_direct_deps_test",
    build_args = [_MISSING_DIRECT_DEPS_TOOLCHAIN],
    expect = ["expected_binary_user_of_binary_buildozer_message.txt"],
    target = "//test/missing_direct_deps/internal_deps:binary_user_of_binary",
)
