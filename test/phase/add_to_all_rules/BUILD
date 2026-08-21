load("@rules_shell//shell:sh_test.bzl", "sh_test")
load(
    "//test/phase/add_to_all_rules:phase_add_to_all_rules_test.bzl",
    "add_to_all_rules_scala_binary",
    "add_to_all_rules_scala_junit_test",
    "add_to_all_rules_scala_library",
    "add_to_all_rules_scala_library_for_plugin_bootstrapping",
    "add_to_all_rules_scala_macro_library",
    "add_to_all_rules_scala_repl",
    "add_to_all_rules_scala_test",
    "add_to_all_rules_singleton",
)

add_to_all_rules_singleton(
    name = "phase_add_to_all_rules",
    visibility = ["//visibility:public"],
)

add_to_all_rules_scala_binary(
    name = "PhaseBinary",
    srcs = ["PhaseBinary.scala"],
    main_class = "scalarules.test.phase.add_to_all_rules.PhaseBinary",
)

add_to_all_rules_scala_library(
    name = "PhaseLibrary",
    srcs = ["PhaseLibrary.scala"],
    custom_content = "This is custom content in library",
)

add_to_all_rules_scala_library_for_plugin_bootstrapping(
    name = "PhaseLibraryForPluginBootstrapping",
    srcs = ["PhaseLibrary.scala"],
    custom_content = "This is custom content in library_for_plugin_bootstrapping",
)

add_to_all_rules_scala_macro_library(
    name = "PhaseMacroLibrary",
    srcs = ["PhaseLibrary.scala"],
    custom_content = "This is custom content in macro_library",
)

add_to_all_rules_scala_test(
    name = "PhaseTest",
    srcs = ["PhaseTest.scala"],
    custom_content = "This is custom content in test",
)

add_to_all_rules_scala_junit_test(
    name = "PhaseJunitTest",
    srcs = ["PhaseJunitTest.scala"],
    custom_content = "This is custom content in junit_test",
    suffixes = ["Test"],
)

add_to_all_rules_scala_repl(
    name = "PhaseRepl",
    srcs = ["PhaseLibrary.scala"],
    custom_content = "This is custom content in repl",
    visibility = ["//test/sh_tests:__pkg__"],
)

# args go through shell tokenization, so a message with spaces needs quoting
# or it silently splits into several argv words.
[
    sh_test(
        name = target + "CustomOutputTest",
        srcs = ["//test/sh_tests:string_in_file.sh"],
        args = [
            "true",
            "'%s'" % message,
            "$(rootpath %s.custom-output)" % target,
        ],
        data = ["%s.custom-output" % target],
    )
    for target, message in [
        ("PhaseBinary", "This is custom content"),
        ("PhaseLibrary", "This is custom content in library"),
        ("PhaseLibraryForPluginBootstrapping", "This is custom content in library_for_plugin_bootstrapping"),
        ("PhaseMacroLibrary", "This is custom content in macro_library"),
        ("PhaseTest", "This is custom content in test"),
        ("PhaseJunitTest", "This is custom content in junit_test"),
        ("PhaseRepl", "This is custom content in repl"),
    ]
]
