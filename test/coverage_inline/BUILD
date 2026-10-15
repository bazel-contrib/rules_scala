load("//scala:scala.bzl", "scala_library", "scala_test")
load("//test/coverage_test:coverage_test.bzl", "coverage_test")

# :app inlines :lib under -Werror, so it only compiles if the compile jar of
# :lib is free of JaCoCo probes: the inliner refuses to copy the probe call.
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
    deps = [":app"],
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
