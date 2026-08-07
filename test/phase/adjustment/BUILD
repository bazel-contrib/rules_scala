load("@rules_shell//shell:sh_test.bzl", "sh_test")
load(
    "//test/phase/adjustment:phase_adjustment_test.bzl",
    "adjustment_replace_scala_library",
    "adjustment_replace_singleton",
    "adjustment_scala_library",
    "adjustment_singleton",
)

adjustment_singleton(
    name = "phase_adjustment",
    visibility = ["//visibility:public"],
)

adjustment_replace_singleton(
    name = "phase_adjustment_replace",
    visibility = ["//visibility:public"],
)

adjustment_scala_library(
    name = "PhaseLibrary",
    srcs = ["PhaseLibrary.scala"],
)

adjustment_replace_scala_library(
    name = "PhaseLibraryReplace",
    srcs = ["PhaseLibrary.scala"],
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
        ("PhaseLibrary", "info from phase_first phase_second redirect info from phase_first info from phase_second"),
        ("PhaseLibraryReplace", "expected info from phase_replace we should only see one info"),
    ]
]
