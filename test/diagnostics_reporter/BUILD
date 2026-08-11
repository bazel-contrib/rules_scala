load("@rules_java//java:defs.bzl", "java_binary")
load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//scala:scala.bzl", "scala_library")
load("//scala:scala_cross_version_select.bzl", "select_for_scala_version")
load("//scala:scala_toolchain.bzl", "scala_toolchain")

java_binary(
    name = "diagnostics_reporter_test",
    srcs = [
        "DiagnosticsReporterTest.java",
        "VerifyDiagnosticsOutput.java",
    ] + select_for_scala_version(
        any_2 = ["DiagnosticsReporterTestCases2.java"],
        any_3 = ["DiagnosticsReporterTestCases3.java"],
    ),
    main_class = "diagnostics_reporter.DiagnosticsReporterTest",
    visibility = ["//visibility:public"],
    deps = [
        "//src/protobuf/io/bazel/rules_scala:diagnostics_java_proto",
    ],
)

scala_toolchain(
    name = "diagnostics_reporter_toolchain_impl",
    enable_diagnostics_report = True,
    visibility = ["//visibility:public"],
)

toolchain(
    name = "diagnostics_reporter_toolchain",
    toolchain = "diagnostics_reporter_toolchain_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_toolchain(
    name = "diagnostics_reporter_and_semanticdb_toolchain_impl",
    enable_diagnostics_report = True,
    enable_semanticdb = True,
    visibility = ["//visibility:public"],
)

toolchain(
    name = "diagnostics_reporter_and_semanticdb_toolchain",
    toolchain = "diagnostics_reporter_and_semanticdb_toolchain_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

# error_file and two_errors_file intentionally fail to compile (that's what
# the diagnostics reporter is asserting on), so they're tagged "manual" to
# stay out of the default `test/...` wildcard build. warning_file and
# info_file below compile fine and need no such tag.
scala_library(
    name = "error_file",
    srcs = ["ErrorFile.scala"],
    tags = ["manual"],
    visibility = ["//visibility:public"],
)

scala_library(
    name = "two_errors_file",
    srcs = ["TwoErrorsFile.scala"],
    tags = ["manual"],
    visibility = ["//visibility:public"],
)

scala_library(
    name = "warning_file",
    srcs = ["WarningFile.scala"],
    scalacopts = select_for_scala_version(
        any_2 = ["-Ywarn-unused:imports"],
        any_3 = ["-Wunused:imports"],
    ),
    visibility = ["//visibility:public"],
)

scala_library(
    name = "error_and_warning_file",
    srcs = ["ErrorAndWarningFile.scala"],
    # Warning: Scala 3 supports -Wunused:imports since Scala 3.3
    scalacopts = select_for_scala_version(
        any_2 = ["-Ywarn-unused:imports"],
        any_3 = ["-Wunused:imports"],
    ),
    # Fails to compile like error_file/two_errors_file above; see the comment there.
    tags = ["manual"],
    visibility = ["//visibility:public"],
)

scala_library(
    name = "info_file",
    srcs = ["InfoFile.scala"],
    # Scala 3 uses absolute paths (which might change) when listing operations of files
    # We're using a stable output from genBCode phase instead
    scalacopts = select_for_scala_version(
        any_2 = ["-Ydebug"],
        any_3 = [
            "-Ylog:genBCode",
            "--verbose",
        ],
    ),
    visibility = ["//visibility:public"],
)

# Absolute labels: the nested `bazel` invocation in diagnostic_proto_files_test.sh
# runs from the workspace root, so a package-relative label would resolve
# against the root package instead of this one.
_FIXTURES = [
    "//test/diagnostics_reporter:error_file",
    "//test/diagnostics_reporter:two_errors_file",
    "//test/diagnostics_reporter:warning_file",
    "//test/diagnostics_reporter:error_and_warning_file",
    "//test/diagnostics_reporter:info_file",
]

# Bazel has no native "run bazel, then run a verifier against its output"
# rule, and unlike expect_build_failure.bzl's macros this test needs two
# nested-bazel steps (build the fixtures, then run the checker against the
# resulting *.diagnosticsproto files), so it can't reuse those macros.
[
    sh_test(
        name = name,
        size = "large",
        srcs = ["diagnostic_proto_files_test.sh"],
        args = [toolchain] + _FIXTURES,
        data = [
            "//:MODULE.bazel",
            "//test/expect_build_failure:nested_bazel.sh",
            # Not redundant with the glob below: this tracks the verifier's
            # own build graph, including its transitive proto dep, which a
            # source-file glob of this package wouldn't see.
            ":diagnostics_reporter_test",
        ] + glob(["**/*"], allow_empty = True),
        tags = [
            "exclusive",
            "local",
            "requires-network",
        ],
    )
    for name, toolchain in {
        "diagnostic_proto_files_test": "//test/diagnostics_reporter:diagnostics_reporter_toolchain",
        "diagnostic_proto_files_semanticdb_test": "//test/diagnostics_reporter:diagnostics_reporter_and_semanticdb_toolchain",
    }.items()
]
