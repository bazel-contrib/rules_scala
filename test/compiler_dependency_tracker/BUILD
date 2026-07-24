load("//scala:scala.bzl", "scala_library")
load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test")

# Dependency-tracking toolchains, registered per-test via `--extra_toolchains`
# (not by default) so the checks below fire only under the tests.
scala_toolchain(
    name = "ast_plus_error_impl",
    compiler_deps_mode = "error",
    dependency_mode = "plus-one",
    dependency_tracking_method = "ast-plus",
    strict_deps_mode = "error",
    unused_dependency_checker_mode = "error",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "ast_plus_error",
    toolchain = ":ast_plus_error_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_toolchain(
    name = "ast_plus_warn_impl",
    compiler_deps_mode = "warn",
    dependency_mode = "plus-one",
    dependency_tracking_method = "ast-plus",
    strict_deps_mode = "warn",
    unused_dependency_checker_mode = "warn",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "ast_plus_warn",
    toolchain = ":ast_plus_warn_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

# Fixtures. The targets a test drives are tagged "manual": they fail under the
# ast_plus_error toolchain (or, for `F`, are intentionally uncompilable), so a
# wildcard build must skip them.
scala_library(
    name = "unused_dep",
    srcs = ["A.scala"],
    tags = ["manual"],
    deps = [":E"],
)

scala_library(
    name = "missing_compile_dep",
    srcs = ["B.scala"],
    tags = ["manual"],
    deps = [":D"],
)

scala_library(
    name = "missing_source_dep",
    srcs = ["C.scala"],
    tags = ["manual"],
    deps = [":D"],
)

scala_library(
    name = "D",
    srcs = ["D.scala"],
    deps = [":E"],
)

scala_library(
    name = "E",
    srcs = ["E.scala"],
)

scala_library(
    name = "F",
    srcs = ["F.scala"],
    tags = ["manual"],
    deps = [":E"],
)

_AST_PLUS_ERROR = "--extra_toolchains=//test/compiler_dependency_tracker:ast_plus_error"

expect_build_failure_test(
    name = "fails_for_unused_dep",
    build_args = [_AST_PLUS_ERROR],
    expect = ["expected_unused_dep.txt"],
    target = ":unused_dep",
)

# Scala 3 variant: guards the bug where the Scala 3 DepsTrackingReporter routed
# synthesized errors to its delegate only, so hasErrors() stayed false and the
# build passed despite printing the error.
expect_build_failure_test(
    name = "scala_3_fails_for_unused_dep",
    build_args = [
        "--repo_env=SCALA_VERSION=3.8.4",
        # Scala 3.8.4's compiler needs Java 17. The nested build does not inherit
        # the repo .bazelrc, so pin the worker JDK here as the outer build does.
        "--tool_java_runtime_version=17",
        "--java_runtime_version=17",
        _AST_PLUS_ERROR,
    ],
    expect = ["expected_unused_dep.txt"],
    target = ":unused_dep",
)

expect_build_failure_test(
    name = "fails_for_missing_compile_dep",
    build_args = [_AST_PLUS_ERROR],
    expect = ["expected_missing_compile_dep.txt"],
    target = ":missing_compile_dep",
)

expect_build_failure_test(
    name = "fails_for_strict_dep",
    build_args = [_AST_PLUS_ERROR],
    expect = ["expected_missing_source_dep.txt"],
    target = ":missing_source_dep",
)

# `F` is uncompilable, so it fails with a plain compile error under the default
# toolchain. The unused-dep checker must not also fire, i.e. no "remove deps".
expect_build_failure_test(
    name = "no_unused_warn_when_broken",
    reject = ["rejected_remove_deps.txt"],
    target = ":F",
)
