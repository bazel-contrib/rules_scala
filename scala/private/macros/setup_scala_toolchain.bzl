load("@rules_scala_config//:config.bzl", "SCALA_VERSION")
load("//scala:providers.bzl", "declare_deps_provider")
load("//scala:scala_cross_version.bzl", "extract_major_version_underscore", "version_suffix")
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
        **kwargs):
    scala_xml_provider = "%s_scala_xml_provider" % name
    parser_combinators_provider = "%s_parser_combinators_provider" % name
    scala_compile_classpath_provider = "%s_scala_compile_classpath_provider" % name
    scala_library_classpath_provider = "%s_scala_library_classpath_provider" % name
    scala_macro_classpath_provider = "%s_scala_macro_classpath_provider" % name
    semanticdb_deps_provider = "%s_semanticdb_deps_provider" % name

    if scala_compile_classpath == None:
        scala_compile_classpath = default_deps("scala_compile_classpath", scala_version)
    declare_deps_provider(
        name = scala_compile_classpath_provider,
        deps_id = "scala_compile_classpath",
        visibility = visibility,
        deps = scala_compile_classpath,
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

    dep_providers = [
        scala_xml_provider,
        parser_combinators_provider,
        scala_compile_classpath_provider,
        scala_library_classpath_provider,
        scala_macro_classpath_provider,
    ]

    if enable_semanticdb == True:
        if semanticdb_deps == None:
            semanticdb_deps = default_deps("semanticdb", scala_version)
        declare_deps_provider(
            name = semanticdb_deps_provider,
            deps_id = "semanticdb",
            deps = semanticdb_deps,
            visibility = visibility,
        )
        dep_providers.append(semanticdb_deps_provider)

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

def default_deps(deps_id, scala_version):
    if deps_id == "parser_combinators":
        if scala_version.startswith("3."):
            target_names = ["org_scala_lang_modules_scala_parser_combinators_2_13"]
        else:
            target_names = [
                "org_scala_lang_modules_scala_parser_combinators_" + extract_major_version_underscore(scala_version),
            ]
    elif deps_id == "scala_compile_classpath":
        target_names = ["org_scala_lang_scala_library"]

        if scala_version.startswith("2."):
            target_names.extend([
                "org_scala_lang_scala_compiler",
                "org_scala_lang_scala_reflect",
            ])
        elif scala_version.startswith("3."):
            target_names.extend([
                "org_scala_lang_modules_scala_asm",
                "org_scala_lang_scala3_compiler_3",
                "org_scala_lang_scala3_library_3",
                "org_scala_lang_scala3_interfaces",
                "org_scala_lang_tasty_core_3",
                "org_scala_sbt_compiler_interface",
            ])
    elif deps_id == "scala_library_classpath" or deps_id == "scala_macro_classpath":
        target_names = ["org_scala_lang_scala_library"]

        if scala_version.startswith("2."):
            target_names.append("org_scala_lang_scala_reflect")
        elif scala_version.startswith("3."):
            target_names.append("org_scala_lang_scala3_library_3")
    elif deps_id == "scala_xml":
        if scala_version.startswith("2."):
            target_names = ["org_scala_lang_modules_scala_xml_" + extract_major_version_underscore(scala_version)]
        else:
            target_names = ["org_scala_lang_modules_scala_xml_3"]
    elif deps_id == "semanticdb":
        if scala_version.startswith("2."):
            target_names = ["org_scalameta_semanticdb_scalac" + version_suffix(scala_version)]
        else:
            target_names = []
    else:
        fail("Unknown deps_id: {}".format(deps_id))

    return [
        "@rules_scala_compiler{}//:{}".format(version_suffix(scala_version), target_name)
        for target_name in target_names
    ]
