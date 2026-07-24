load("//scala:scala.bzl", "scala_library")
load(
    "//test/expect_build_failure:expect_build_failure.bzl",
    "expect_build_failure_test",
    "expect_build_success_test",
)

# Targets exercising Scala 3 `given` imports under the ast_plus_error toolchain,
# driven by the given_import_* tests below.
#
# More targeted coverage of the underlying analyzer behavior lives in
# the unit tests at
# third_party/dependency_analyzer/src/test/.../AstUsedJarFinderTest.scala
# and runs against every supported Scala 3 version. These targets pin a
# single version because the shell test needs a concrete Scala 3
# toolchain and the behavior under test is not version-specific.
SCALA_3_VERSION = "3.7.4"

scala_library(
    name = "tc",
    srcs = ["TC.scala"],
    scala_version = SCALA_3_VERSION,
    visibility = ["//visibility:public"],
)

scala_library(
    name = "givens",
    srcs = ["Givens.scala"],
    scala_version = SCALA_3_VERSION,
    visibility = ["//visibility:public"],
    deps = [":tc"],
)

# Builds successfully under the ast_plus_error toolchain: `:givens`
# provides the given that `:tc` requires through implicit search.
scala_library(
    name = "user",
    srcs = ["User.scala"],
    scala_version = SCALA_3_VERSION,
    tags = ["manual"],
    visibility = ["//visibility:public"],
    deps = [
        ":givens",
        ":tc",
    ],
)

# Same source as `:user` but with `:givens` removed from `deps`.
# Building it must fail with a "no given instance" error, anchoring
# the assumption that `:givens` is genuinely required by `:user`.
scala_library(
    name = "user_missing_given_dep",
    srcs = ["UserMissingGivenDep.scala"],
    scala_version = SCALA_3_VERSION,
    tags = ["manual"],
    visibility = ["//visibility:public"],
    deps = [
        ":tc",
    ],
)

# `:user` builds cleanly under ast_plus_error (unused-dep checker set to error):
# the given dep `:givens`, used only through implicit search, is not flagged.
expect_build_success_test(
    name = "given_import_is_not_unused",
    build_args = ["--extra_toolchains=//test/compiler_dependency_tracker:ast_plus_error"],
    target = ":user",
)

expect_build_failure_test(
    name = "given_import_breaks_when_dep_removed",
    build_args = ["--extra_toolchains=//test/compiler_dependency_tracker:ast_plus_error"],
    expect = ["expected_no_given_instance.txt"],
    target = ":user_missing_given_dep",
)
