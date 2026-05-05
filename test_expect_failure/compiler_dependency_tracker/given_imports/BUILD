load("//scala:scala.bzl", "scala_library")

# Targets exercising Scala 3 `given` imports under the
# `ast_plus_error` toolchain. Driven by
# test/shell/test_compiler_dependency_tracking.sh.
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
    visibility = ["//visibility:public"],
    deps = [
        ":tc",
    ],
)
