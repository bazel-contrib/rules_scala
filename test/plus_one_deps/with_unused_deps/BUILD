load("//scala:scala.bzl", "scala_library")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test", "expect_build_success_test")

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
    build_args = ["--extra_toolchains=//test_expect_failure/plus_one_deps:plus_one_deps_with_unused_error"],
    target = ":a",
)

expect_build_failure_test(
    name = "ast_analyzer_unused_deps_error_test",
    build_args = ["--extra_toolchains=//test/toolchains:ast_plus_one_deps_unused_deps_error"],
    target = ":a",
)

expect_build_failure_test(
    name = "ast_analyzer_unused_deps_strict_deps_error_test",
    build_args = ["--extra_toolchains=//scala:minimal_direct_source_deps"],
    target = ":a",
)

expect_build_success_test(
    name = "ast_analyzer_unused_deps_warn_test",
    build_args = ["--extra_toolchains=//test/toolchains:ast_plus_one_deps_unused_deps_warn"],
    expect = ["expected_unused_deps_warning.txt"],
    target = ":a",
)
