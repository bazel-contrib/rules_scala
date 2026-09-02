load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("//scala:scala.bzl", "scala_library")
load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test", "expect_build_success_test")
load(":toolchain_transition.bzl", "build_under_toolchains")

scala_toolchain(
    name = "failing_toolchain_impl",
    unused_dependency_checker_mode = "error",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "failing_scala_toolchain",
    toolchain = "failing_toolchain_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_library(
    name = "B",
    srcs = ["B.scala"],
)

# `A` has an unused dep on `B`; each target below flips a different knob
# (rule-level attribute, toolchain default, or a rule-level override of a
# failing toolchain) to control whether that unused dep is an error.
scala_library(
    name = "failing_build",
    srcs = ["A.scala"],
    tags = ["manual"],
    unused_dependency_checker_mode = "error",
    deps = [":B"],
)

scala_library(
    name = "toolchain_failing_build",
    srcs = ["A.scala"],
    tags = ["manual"],
    deps = [":B"],
)

scala_library(
    name = "toolchain_override",
    srcs = ["A.scala"],
    tags = ["manual"],
    unused_dependency_checker_mode = "off",
    deps = [":B"],
)

expect_build_failure_test(
    name = "mode_set_in_rule_fails_test",
    target = ":failing_build",
)

expect_build_failure_test(
    name = "mode_from_scala_toolchain_fails_test",
    build_args = ["--extra_toolchains=//test/unused_dependency_checker:failing_scala_toolchain"],
    target = ":toolchain_failing_build",
)

build_under_toolchains(
    name = "toolchain_override_under_failing_scala_toolchain",
    testonly = True,
    extra_toolchains = ["//test/unused_dependency_checker:failing_scala_toolchain"],
    target = ":toolchain_override",
)

build_test(
    name = "mode_override_toolchain_succeeds_test",
    targets = [":toolchain_override_under_failing_scala_toolchain"],
)

# `target` lives in //test, not this package: its sources aren't tracked as
# this test's runfiles (see expect_build_failure.bzl), so an edit there won't
# force a re-run. The fixture is long-standing and rarely touched.
expect_build_success_test(
    name = "mode_warn_test",
    build_args = ["--extra_toolchains=//test/toolchains:high_level_direct_deps"],
    expect = ["expected_unused_dependency_checker_warning.txt"],
    target = "//test:UnusedDependencyCheckerWarn",
)

# `target` lives in //test/scala_test, not this package: see the comment above
# on mode_warn_test.
build_under_toolchains(
    name = "scala_test_b_under_ast_plus_one_deps_unused_deps_error",
    testonly = True,
    extra_toolchains = ["//test/toolchains:ast_plus_one_deps_unused_deps_error"],
    target = "//test/scala_test:b",
)

build_test(
    name = "ast_analyzer_no_scalatest_unused_dep_warning_test",
    targets = [":scala_test_b_under_ast_plus_one_deps_unused_deps_error"],
)
