load("//scala:scala.bzl", "scala_binary", "scala_library", "scala_macro_library", "scala_test")
load("//test/coverage_test:coverage_test.bzl", "coverage_test")

# `bazel coverage` instruments every non-test target in this package (the
# default --instrumentation_filter), so the instrumented classes call the JaCoCo
# runtime from two places: the macro while scalac expands it, and the binary
# at run time.
coverage_test(
    name = "coverage_with_macro_and_binary_test",
    expected_line = "SF:test/coverage_jacoco_runtime/Helper.scala",
    target = ":test",
)

# Same macro check for Scala 3, whose macros load classes through their own
# class loader. The *_scala3 targets are `manual` so the Scala 2 build of this
# package skips them.
coverage_test(
    name = "coverage_with_scala3_macro_test",
    bazel_args = ["--repo_env=SCALA_VERSION=3.3.8"],
    expected_line = "SF:test/coverage_jacoco_runtime/UserScala3.scala",
    target = ":test_scala3",
)

scala_test(
    name = "test_scala3",
    srcs = ["JacocoRuntimeScala3Test.scala"],
    tags = ["manual"],
    deps = [":user_scala3"],
)

scala_library(
    name = "user_scala3",
    srcs = ["UserScala3.scala"],
    tags = ["manual"],
    deps = [":macro_scala3"],
)

scala_macro_library(
    name = "macro_scala3",
    srcs = ["MacroScala3.scala"],
    tags = ["manual"],
    deps = [":helper"],
)

scala_test(
    name = "test",
    srcs = ["JacocoRuntimeTest.scala"],
    data = [":bin"],
    deps = [":user"],
)

scala_binary(
    name = "bin",
    srcs = ["Main.scala"],
    main_class = "coverage_jacoco_runtime.Main",
    deps = [":helper"],
)

scala_library(
    name = "user",
    srcs = ["User.scala"],
    deps = [":macro"],
)

scala_macro_library(
    name = "macro",
    srcs = ["Macro.scala"],
    deps = [":helper"],
)

scala_library(
    name = "helper",
    srcs = ["Helper.scala"],
)
