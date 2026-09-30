load("//scala:scala.bzl", "scala_library", "scala_repl")
load("//scala:scala_toolchain.bzl", "scala_toolchain")
load(
    "//test/expect_build_failure:expect_build_failure.bzl",
    "expect_build_success_test",
)

# The dep_providers list a caller wrote before scala_repl_classpath existed:
# _default_dep_providers() minus scala_repl_classpath. phase_scalac_provider.bzl
# must fall back to the compile classpath for a toolchain like this one.
scala_toolchain(
    name = "legacy_toolchain_impl",
    dep_providers = [
        "@rules_scala_toolchains//scala:scala_xml_provider",
        "@rules_scala_toolchains//scala:parser_combinators_provider",
        "@rules_scala_toolchains//scala:scala_compile_classpath_provider",
        "@rules_scala_toolchains//scala:scala_library_classpath_provider",
        "@rules_scala_toolchains//scala:scala_macro_classpath_provider",
        "@rules_scala_toolchains//scala:semanticdb_provider",
    ],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "legacy_scala_toolchain",
    toolchain = ":legacy_toolchain_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

# Tagged "manual": the test below builds them with legacy_scala_toolchain
# forced in via --extra_toolchains, which compiles legacy_lib under it too.
scala_library(
    name = "legacy_lib",
    srcs = ["Legacy.scala"],
    tags = ["manual"],
)

scala_repl(
    name = "legacy_repl",
    tags = ["manual"],
    deps = [":legacy_lib"],
)

_LEGACY_TOOLCHAIN = "--extra_toolchains=//test/toolchains/scala_repl_classpath_fallback:legacy_scala_toolchain"

expect_build_success_test(
    name = "scala_repl_builds_under_legacy_toolchain_test",
    build_args = [_LEGACY_TOOLCHAIN],
    target = ":legacy_repl",
)
