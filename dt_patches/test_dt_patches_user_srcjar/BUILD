load("@rules_scala//scala:scala.bzl", "setup_scala_toolchain")
load(
    "@rules_scala//scala:scala_cross_version_select.bzl",
    "select_for_scala_version",
)

SCALA_LIBS = ["@scala_compiler//:org_scala_lang_scala_library"] + select_for_scala_version(
    any_2 = ["@scala_compiler//:org_scala_lang_scala_reflect"],
    any_3 = [
        "@scala_compiler//:org_scala_lang_modules_scala_asm",
        "@scala_compiler//:org_scala_lang_scala3_interfaces",
        "@scala_compiler//:org_scala_lang_scala3_library_3",
        "@scala_compiler//:org_scala_lang_tasty_core_3",
    ],
    since_3_4 = ["@scala_compiler//:org_scala_sbt_compiler_interface"],
)

setup_scala_toolchain(
    name = "dt_scala_toolchain",
    parser_combinators_deps = [],
    scala_compile_classpath = select_for_scala_version(
        any_2 = ["@scala_compiler//:org_scala_lang_scala_compiler"],
        any_3 = ["@scala_compiler//:org_scala_lang_scala3_compiler_3"],
    ) + SCALA_LIBS,
    scala_library_classpath = SCALA_LIBS,
    scala_macro_classpath = SCALA_LIBS,
    scala_xml_deps = [],
)
