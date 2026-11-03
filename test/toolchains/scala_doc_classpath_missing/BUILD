load("//scala:scala_toolchain.bzl", "scala_toolchain")

# The dep_providers list a caller wrote before scala_doc_classpath existed:
# _default_dep_providers() minus scala_doc_classpath. Scala 3 scala_doc must
# fail in analysis for a toolchain like this one.
scala_toolchain(
    name = "toolchain_impl",
    dep_providers = [
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
    target_settings = ["@rules_scala_config//:scala_version_3_7_4"],
    toolchain = ":toolchain_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//test/scaladoc:__pkg__"],
)
