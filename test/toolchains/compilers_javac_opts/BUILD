load("//scala:scala.bzl", "scala_library")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test")

# Migrated from test/shell/test_toolchain.sh
# (java_toolchain_javacopts_are_used / java_toolchain_javacopts_can_be_overridden).
#
# The fixtures fail to compile once an invalid javac flag reaches the compiler
# (either via `--javacopt` on the command line, or a bad target `javacopts`).
# They are tagged "manual" so wildcard builds skip them; the sh_tests drive a
# nested `bazel build` and assert the compiler surfaces the invalid flag.

scala_library(
    name = "can_configure_jvm_flags_for_javac_via_javacopts",
    srcs = ["WillNotCompileSinceJavaToolchainAddsAnInvalidJvmFlag.java"],
    tags = ["manual"],
)

scala_library(
    name = "can_override_default_toolchain_flags_for_javac_via_javacopts",
    srcs = ["WillNotCompileSinceJavaToolchainAddsAnInvalidJvmFlag.java"],
    javacopts = ["-target InvalidTarget"],
    tags = ["manual"],
)

expect_build_failure_test(
    name = "javac_javacopts_are_used_build_test",
    build_args = [
        "--javacopt=-InvalidFlag",
        "--verbose_failures",
    ],
    expect = ["expected_invalid_flag.txt"],
    target = "//test/toolchains/compilers_javac_opts:can_configure_jvm_flags_for_javac_via_javacopts",
)

expect_build_failure_test(
    name = "javac_javacopts_can_be_overridden_build_test",
    build_args = ["--verbose_failures"],
    expect = ["expected_invalid_target.txt"],
    target = "//test/toolchains/compilers_javac_opts:can_override_default_toolchain_flags_for_javac_via_javacopts",
)
