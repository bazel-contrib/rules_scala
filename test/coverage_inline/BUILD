load("//scala:scala.bzl", "scala_library", "scala_macro_library", "scala_test")
load("//test/coverage_test:coverage_test.bzl", "coverage_test")

# Each app inlines :lib or :check under -Werror, so it compiles only if scalac
# reads their classes before instrumentation: the inliner refuses to copy a
# JaCoCo probe call. The runtime jars of a macro library come first on the
# compile classpath. :mac gets :lib through the exports of :lib_exported, and
# Mac.twice calls Lib.twice while scalac expands the macro. :check gets :lib
# only as a runtime dependency.
# Pinned to 2.13, whose -opt:inline flag the 2.12 default doesn't accept, so the
# fixtures are `manual` and the default build skips them.
coverage_test(
    name = "coverage_with_inlined_dependency_test",
    bazel_args = ["--repo_env=SCALA_VERSION=2.13.18"],
    expected_line = "SF:test/coverage_inline/App.scala",
    target = ":test",
)

scala_test(
    name = "test",
    srcs = ["InlineTest.scala"],
    tags = ["manual"],
    deps = [
        ":app",
        ":checked_app",
        ":macro_app",
    ],
)

scala_library(
    name = "app",
    srcs = ["App.scala"],
    scalacopts = [
        "-opt:inline:**",
        "-Werror",
        "-Wopt",
    ],
    tags = ["manual"],
    deps = [":lib"],
)

scala_library(
    name = "lib",
    srcs = ["Lib.scala"],
    build_ijar = False,
    tags = ["manual"],
)

scala_library(
    name = "lib_exported",
    tags = ["manual"],
    exports = [":lib"],
)

scala_macro_library(
    name = "mac",
    srcs = ["Mac.scala"],
    tags = ["manual"],
    deps = [":lib_exported"],
)

scala_library(
    name = "macro_app",
    srcs = ["MacroApp.scala"],
    scalacopts = [
        "-opt:inline:**",
        "-Werror",
        "-Wopt",
    ],
    tags = ["manual"],
    deps = [
        ":lib",
        ":mac",
    ],
)

scala_library(
    name = "checked_app",
    srcs = ["CheckedApp.scala"],
    scalacopts = [
        "-opt:inline:**",
        "-Werror",
        "-Wopt",
    ],
    tags = ["manual"],
    deps = [
        ":check",
        ":lib",
    ],
)

scala_macro_library(
    name = "check",
    srcs = ["Check.scala"],
    tags = ["manual"],
    runtime_deps = [":lib"],
)

# The same check for Scala 3.9. Its inliner reads method inline info only from
# targets that compile with -opt-inline. With the instrumented classes, it
# copies the JaCoCo probes of Lib.twice into the macro app, and the test fails
# at run time with an IllegalAccessError. The apps with a macro dependency turn
# off the unused dependency checker, so the build reaches this failure (#2036).
SCALA3_LIBRARY_OPTS = ["-opt-inline:**"]

SCALA3_APP_OPTS = [
    "-opt",
    "-opt-inline:**",
    "-Werror",
    "-Wopt:at-inline-failed",
]

coverage_test(
    name = "coverage_with_inlined_dependency_scala3_test",
    bazel_args = ["--repo_env=SCALA_VERSION=3.9.0"],
    expected_line = "SF:test/coverage_inline/App.scala",
    target = ":test_scala3",
)

scala_test(
    name = "test_scala3",
    srcs = ["InlineTest.scala"],
    tags = ["manual"],
    deps = [
        ":app_scala3",
        ":checked_app_scala3",
        ":macro_app_scala3",
    ],
)

scala_library(
    name = "app_scala3",
    srcs = ["App.scala"],
    scalacopts = SCALA3_APP_OPTS,
    tags = ["manual"],
    deps = [":lib_scala3"],
)

scala_library(
    name = "lib_scala3",
    srcs = ["Lib.scala"],
    build_ijar = False,
    scalacopts = SCALA3_LIBRARY_OPTS,
    tags = ["manual"],
)

scala_library(
    name = "lib_exported_scala3",
    tags = ["manual"],
    exports = [":lib_scala3"],
)

scala_macro_library(
    name = "mac_scala3",
    srcs = ["MacScala3.scala"],
    scalacopts = SCALA3_LIBRARY_OPTS,
    tags = ["manual"],
    deps = [":lib_exported_scala3"],
)

scala_library(
    name = "macro_app_scala3",
    srcs = ["MacroApp.scala"],
    scalacopts = SCALA3_APP_OPTS,
    tags = ["manual"],
    unused_dependency_checker_mode = "off",
    deps = [
        ":lib_scala3",
        ":mac_scala3",
    ],
)

scala_library(
    name = "checked_app_scala3",
    srcs = ["CheckedApp.scala"],
    scalacopts = SCALA3_APP_OPTS,
    tags = ["manual"],
    unused_dependency_checker_mode = "off",
    deps = [
        ":check_scala3",
        ":lib_scala3",
    ],
)

scala_macro_library(
    name = "check_scala3",
    srcs = ["Check.scala"],
    scalacopts = SCALA3_LIBRARY_OPTS,
    tags = ["manual"],
    runtime_deps = [":lib_scala3"],
)
