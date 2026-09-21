load("@rules_scala_config//:config.bzl", "SCALA_VERSION")
load("//scala:providers.bzl", "declare_deps_provider")
load("//scala:scala_cross_version.bzl", "repositories", "version_suffix")
load("//scala:scala_toolchain.bzl", "scala_toolchain")

def setup_scala_toolchain(
        name,
        scala_compile_classpath = None,
        scala_library_classpath = None,
        scala_macro_classpath = None,
        scala_version = SCALA_VERSION,
        scala_xml_deps = None,
        parser_combinators_deps = None,
        semanticdb_deps = None,
        enable_semanticdb = False,
        visibility = ["//visibility:public"],
        scala_repl_classpath = None,
        **kwargs):
    scala_xml_provider = "%s_scala_xml_provider" % name
    parser_combinators_provider = "%s_parser_combinators_provider" % name
    scala_compile_classpath_provider = "%s_scala_compile_classpath_provider" % name
    scala_library_classpath_provider = "%s_scala_library_classpath_provider" % name
    scala_macro_classpath_provider = "%s_scala_macro_classpath_provider" % name
    scala_repl_classpath_provider = "%s_scala_repl_classpath_provider" % name
    semanticdb_deps_provider = "%s_semanticdb_deps_provider" % name

    if scala_compile_classpath == None:
        scala_compile_classpath = default_deps("scala_compile_classpath", scala_version)
    declare_deps_provider(
        name = scala_compile_classpath_provider,
        deps_id = "scala_compile_classpath",
        visibility = visibility,
        deps = scala_compile_classpath,
    )

    if scala_repl_classpath == None:
        scala_repl_classpath = scala_compile_classpath + repositories(scala_version, repl_extra_deps(scala_version))
    declare_deps_provider(
        name = scala_repl_classpath_provider,
        deps_id = "scala_repl_classpath",
        visibility = visibility,
        deps = scala_repl_classpath,
    )

    if scala_library_classpath == None:
        scala_library_classpath = default_deps("scala_library_classpath", scala_version)
    declare_deps_provider(
        name = scala_library_classpath_provider,
        deps_id = "scala_library_classpath",
        visibility = visibility,
        deps = scala_library_classpath,
    )

    if scala_macro_classpath == None:
        scala_macro_classpath = default_deps("scala_macro_classpath", scala_version)
    declare_deps_provider(
        name = scala_macro_classpath_provider,
        deps_id = "scala_macro_classpath",
        visibility = visibility,
        deps = scala_macro_classpath,
    )

    if scala_xml_deps == None:
        scala_xml_deps = default_deps("scala_xml", scala_version)
    declare_deps_provider(
        name = scala_xml_provider,
        deps_id = "scala_xml",
        visibility = visibility,
        deps = scala_xml_deps,
    )

    if parser_combinators_deps == None:
        parser_combinators_deps = default_deps("parser_combinators", scala_version)
    declare_deps_provider(
        name = parser_combinators_provider,
        deps_id = "parser_combinators",
        visibility = visibility,
        deps = parser_combinators_deps,
    )

    if semanticdb_deps == None:
        semanticdb_deps = default_deps("semanticdb", scala_version) if enable_semanticdb else []
    declare_deps_provider(
        name = semanticdb_deps_provider,
        deps_id = "semanticdb",
        deps = semanticdb_deps,
        visibility = visibility,
    )

    dep_providers = [
        scala_xml_provider,
        parser_combinators_provider,
        scala_compile_classpath_provider,
        scala_library_classpath_provider,
        scala_macro_classpath_provider,
        scala_repl_classpath_provider,
        semanticdb_deps_provider,
    ]

    scala_toolchain(
        name = "%s_impl" % name,
        dep_providers = dep_providers,
        enable_semanticdb = enable_semanticdb,
        visibility = visibility,
        **kwargs
    )

    native.toolchain(
        name = name,
        toolchain = ":%s_impl" % name,
        toolchain_type = Label("//scala:toolchain_type"),
        target_settings = [
            Label(
                "@rules_scala_config//:scala_version" +
                version_suffix(scala_version),
            ),
        ],
        visibility = visibility,
    )

_DEFAULT_DEPS = {
    "scala_compile_classpath": {
        "any": [
            "@io_bazel_rules_scala_scala_compiler",
            "@io_bazel_rules_scala_scala_library",
        ],
        "2": [
            "@io_bazel_rules_scala_scala_reflect",
        ],
        "3": [
            "@io_bazel_rules_scala_scala_interfaces",
            "@io_bazel_rules_scala_scala_tasty_core",
            "@io_bazel_rules_scala_scala_asm",
            "@io_bazel_rules_scala_scala_library_2",
            "@org_scala_sbt_compiler_interface",
        ],
    },
    "scala_library_classpath": {
        "any": [
            "@io_bazel_rules_scala_scala_library",
        ],
        "2": [
            "@io_bazel_rules_scala_scala_reflect",
        ],
        "3": [
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "scala_macro_classpath": {
        "any": [
            "@io_bazel_rules_scala_scala_library",
        ],
        "2": [
            "@io_bazel_rules_scala_scala_reflect",
        ],
        "3": [
            "@io_bazel_rules_scala_scala_library_2",
        ],
    },
    "scala_xml": {
        "any": ["@io_bazel_rules_scala_scala_xml"],
    },
    "parser_combinators": {
        "any": ["@io_bazel_rules_scala_scala_parser_combinators"],
    },
    "semanticdb": {
        "2": ["@org_scalameta_semanticdb_scalac"],
    },
}

def default_deps(deps_id, scala_version):
    versions = _DEFAULT_DEPS[deps_id]
    deps = versions.get("any", []) + versions.get(scala_version[0], [])
    return repositories(scala_version, deps)

# scala_repl's extra deps key off the exact minor version, finer-grained
# than _DEFAULT_DEPS's "any"/"2"/"3" major-version buckets: from 3.8
# dotty.tools.repl.Main moved into its own artifact, and 3.9 changed that
# artifact's own deps again (see phase_write_executable_repl and the two
# third_party/repositories/scala_3_{8,9}.bzl files for the full story).
_REPL_EXTRA_DEPS = {
    "3.8.": [
        "@com_lihaoyi_fansi_3",
        "@com_lihaoyi_pprint_repl",
        "@com_lihaoyi_sourcecode_3",
        "@io_get_coursier_interface",
        "@org_scala_lang_scala3_repl",
        "@org_slf4j_slf4j_api",
        "@org_virtuslab_using_directives",
    ],
    "3.9.": [
        "@io_get_coursier_interface",
        "@org_jline_jline_native_4",
        "@org_jline_jline_reader_4",
        "@org_jline_jline_terminal_4",
        "@org_jline_jline_terminal_jni_4",
        "@org_scala_lang_scala3_directives_parser",
        "@org_scala_lang_scala3_repl",
        "@org_slf4j_slf4j_api",
    ],
}

def repl_extra_deps(scala_version):
    """The extra deps a scala_repl needs on top of scala_compile_classpath.

    Returns [] both for a Scala 3 minor version that genuinely needs nothing
    extra (3.1 through 3.7: dotty.tools.repl.Main still lives inside
    scala3-compiler there) and for one this mapping has yet to cover.
    repl_is_known_supported, called at scala_repl analysis time, is what
    tells those two apart.
    """
    for prefix, deps in _REPL_EXTRA_DEPS.items():
        if scala_version.startswith(prefix):
            return deps
    return []

def repl_is_known_supported(scala_version):
    """False for a Scala 3 minor version >= 3.8 with no repl_extra_deps entry.

    3.8 and 3.9 each changed scala_repl's own deps once already, so treat a
    future 3.x minor this mapping has yet to cover as unknown territory,
    requiring an update here, rather than assuming it needs nothing:
    silently assuming that would build a scala_repl that fails at runtime
    with ClassNotFoundException. Called only when a scala_repl target is
    actually analyzed, scoping the check to the targets it actually concerns
    rather than every general toolchain/repository setup.
    """
    if not scala_version.startswith("3.") or int(scala_version.split(".")[1]) < 8:
        return True
    return repl_extra_deps(scala_version) != []
