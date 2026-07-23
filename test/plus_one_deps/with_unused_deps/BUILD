load("//scala:scala.bzl", "scala_library")
load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test", "expect_build_success_test")

# Plus-one dependency mode with the unused-dependency checker set to "error".
# Registered per-test via `--extra_toolchains` (not by default), so `:a`'s unused
# direct dep on `:c` is reported as an error.
scala_toolchain(
    name = "plus_one_deps_with_unused_error_impl",
    dependency_mode = "plus-one",
    unused_dependency_checker_mode = "error",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "plus_one_deps_with_unused_error",
    toolchain = "plus_one_deps_with_unused_error_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

# `a` directly depends on both `b` and `c`, but only uses `b` in its source; `c`
# is also reachable transitively through `b`. Under "plus-one" dependency mode
# with the unused-dependency checker on, the direct dep on `c` is flagged as
# unused. Tagged "manual" so wildcard builds skip it; the default toolchain
# doesn't enable the checker, so it would otherwise just build cleanly.
scala_library(
    name = "a",
    srcs = ["A.scala"],
    tags = ["manual"],
    deps = [
        ":b",
        ":c",
    ],
)

scala_library(
    name = "b",
    srcs = ["B.scala"],
    deps = [":c"],
)

scala_library(
    name = "c",
    srcs = ["C.scala"],
)

expect_build_failure_test(
    name = "unused_dep_fails_with_toolchain_unused_error_test",
    build_args = ["--extra_toolchains=//test/plus_one_deps/with_unused_deps:plus_one_deps_with_unused_error"],
    expect = ["expected_unused_dep_error.txt"],
    target = ":a",
)

expect_build_failure_test(
    name = "ast_analyzer_unused_deps_error_test",
    build_args = ["--extra_toolchains=//test/toolchains:ast_plus_one_deps_unused_deps_error"],
    expect = ["expected_unused_dep_error.txt"],
    target = ":a",
)

expect_build_failure_test(
    name = "ast_analyzer_unused_deps_strict_deps_error_test",
    build_args = ["--extra_toolchains=//scala:minimal_direct_source_deps"],
    expect = ["expected_unused_dep_error.txt"],
    # Seen timing out on Windows CI queuing for the shared nested-bazel lock.
    size = "enormous",
    target = ":a",
)

expect_build_success_test(
    name = "ast_analyzer_unused_deps_warn_test",
    build_args = ["--extra_toolchains=//test/toolchains:ast_plus_one_deps_unused_deps_warn"],
    expect = ["expected_unused_deps_warning.txt"],
    target = ":a",
)
