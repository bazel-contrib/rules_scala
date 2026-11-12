load("//scala:providers.bzl", "declare_deps_provider")
load("//scala:scala_cross_version.bzl", "version_suffix")
load("//scala:scala_toolchain.bzl", "scala_toolchain")

# Scaladoc 3.3.9 with the Scala 3.9.0 compiler. Scala 3 scala_doc must fail in
# analysis for this toolchain.
declare_deps_provider(
    name = "scala_doc_classpath_provider",
    deps_id = "scala_doc_classpath",
    deps = ["@io_bazel_rules_scala_scaladoc_3_3_9"],
)

scala_toolchain(
    name = "toolchain_impl",
    dep_providers = [
        ":scala_doc_classpath_provider",
        "@rules_scala_toolchains//scala:scala_xml_provider",
        "@rules_scala_toolchains//scala:parser_combinators_provider",
        "@rules_scala_toolchains//scala:scala_compile_classpath_provider",
        "@rules_scala_toolchains//scala:scala_library_classpath_provider",
        "@rules_scala_toolchains//scala:scala_macro_classpath_provider",
        "@rules_scala_toolchains//scala:scala_repl_classpath_provider",
        "@rules_scala_toolchains//scala:semanticdb_provider",
    ],
)

toolchain(
    name = "toolchain",
    target_settings = ["@rules_scala_config//:scala_version" + version_suffix("3.9.0")],
    toolchain = ":toolchain_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//test/scaladoc:__pkg__"],
)
