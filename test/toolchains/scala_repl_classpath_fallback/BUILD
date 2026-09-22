load("//scala:scala.bzl", "scala_library", "scala_repl")
load("//scala:scala_toolchain.bzl", "scala_toolchain")
load(
    "//test/expect_build_failure:expect_build_failure.bzl",
    "expect_build_success_test",
)

# Mirrors the dep_providers set a caller from before scala_repl_classpath
# existed would have built: everything scala_repl_classpath now adds, minus
# scala_repl_classpath itself. phase_scalac_provider.bzl's
# find_deps_info_on_if_present must fall back to the plain compile classpath
# for a toolchain like this one.
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

# Tagged "manual": these only build successfully with legacy_scala_toolchain
# forced in via --extra_toolchains, so a plain `bazel build //...` would
# otherwise run them under the default toolchain instead.
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
    name = "scala_library_builds_under_legacy_toolchain_test",
    build_args = [_LEGACY_TOOLCHAIN],
    target = ":legacy_lib",
)

expect_build_success_test(
    name = "scala_repl_builds_under_legacy_toolchain_test",
    build_args = [_LEGACY_TOOLCHAIN],
    target = ":legacy_repl",
)
