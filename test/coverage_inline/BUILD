load("//scala:scala.bzl", "scala_library", "scala_macro_library", "scala_test")
load("//test/coverage_test:coverage_test.bzl", "coverage_test")

# :app and :macro_app inline :lib under -Werror, so they only compile if the
# classes of :lib on their compile classpath are free of JaCoCo probes: the
# inliner refuses to copy the probe call. :macro_app also depends on :mac. The
# jars of :mac and :lib come first on its compile classpath, and Mac.twice calls
# Lib.twice while scalac expands the macro. :checked_app inlines a method of the
# macro library :check itself, without expanding a macro.
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

scala_macro_library(
    name = "mac",
    srcs = ["Mac.scala"],
    tags = ["manual"],
    deps = [":lib"],
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
    deps = [":check"],
)

scala_macro_library(
    name = "check",
    srcs = ["Check.scala"],
    tags = ["manual"],
)
