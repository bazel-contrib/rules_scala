load("//scala:scala.bzl", "scala_library")
load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test", "expect_build_success_test")

toolchain(
    name = "plus_one_strict_deps_filter",
    toolchain = ":plus_one_strict_deps_filter_a_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_toolchain(
    name = "plus_one_strict_deps_filter_a_impl",
    dependency_mode = "plus-one",
    dependency_tracking_method = "ast",
    dependency_tracking_strict_deps_patterns = [
        "@//test/strict_dependency/filtering",
        "-@//test/strict_dependency/filtering:a",
    ],
    strict_deps_mode = "error",
    visibility = ["//visibility:public"],
)

scala_library(
    name = "transitive_deps",
    testonly = True,
    srcs = ["UsesGuava.scala"],
    deps = ["@com_google_guava_guava_21_0"],
)

# :a and :b both only resolve com.google.common under plus-one dependency mode.

scala_library(
    name = "a",
    testonly = True,
    srcs = ["UsesGuava.scala"],
    tags = ["manual"],
    deps = [":transitive_deps"],
)

scala_library(
    name = "b",
    testonly = True,
    srcs = ["UsesGuava.scala"],
    tags = ["manual"],
    deps = [":transitive_deps"],
)

expect_build_success_test(
    name = "strict_deps_filter_excluded_target_test",
    build_args = ["--extra_toolchains=//test/strict_dependency/filtering:plus_one_strict_deps_filter"],
    target = ":a",
)

expect_build_failure_test(
    name = "strict_deps_filter_included_target_test",
    build_args = ["--extra_toolchains=//test/strict_dependency/filtering:plus_one_strict_deps_filter"],
    expect = ["expected_filter_included_missing_guava.txt"],
    target = ":b",
)
