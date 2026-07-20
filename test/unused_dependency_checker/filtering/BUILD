load("//scala:scala.bzl", "scala_library")
load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test", "expect_build_success_test")

toolchain(
    name = "plus_one_unused_deps_filter",
    toolchain = ":plus_one_unused_deps_filter_a_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_toolchain(
    name = "plus_one_unused_deps_filter_a_impl",
    dependency_mode = "plus-one",
    dependency_tracking_method = "ast",
    dependency_tracking_unused_deps_patterns = [
        "@//test/unused_dependency_checker/filtering",
        "-@//test/unused_dependency_checker/filtering:a",
    ],
    unused_dependency_checker_mode = "error",
    visibility = ["//visibility:public"],
)

# `a` is excluded from the toolchain's unused-deps pattern, so its unused guava
# dep is not flagged; `b` is included, so the same unused dep fails the build.
# Both tagged "manual": the default toolchain doesn't enable the checker, so
# `b` would otherwise just build cleanly under a plain wildcard build.
scala_library(
    name = "a",
    testonly = True,
    srcs = ["Empty.scala"],
    tags = ["manual"],
    deps = ["@com_google_guava_guava_21_0"],
)

scala_library(
    name = "b",
    testonly = True,
    srcs = ["Empty.scala"],
    tags = ["manual"],
    deps = ["@com_google_guava_guava_21_0"],
)

expect_build_success_test(
    name = "excluded_target_succeeds_test",
    build_args = ["--extra_toolchains=//test/unused_dependency_checker/filtering:plus_one_unused_deps_filter"],
    target = ":a",
)

expect_build_failure_test(
    name = "included_target_fails_test",
    build_args = ["--extra_toolchains=//test/unused_dependency_checker/filtering:plus_one_unused_deps_filter"],
    expect = ["expected_unused_guava_dep.txt"],
    target = ":b",
)
