load("@rules_java//java:defs.bzl", "java_library")
load("//scala:scala.bzl", "scala_binary", "scala_library", "scala_macro_library", "scala_test")
load("//test/coverage_test:coverage_test.bzl", "coverage_test")

# `bazel coverage` instruments every library and binary in this package (the
# default --instrumentation_filter), so the instrumented classes also call the
# JaCoCo runtime outside the test JVM: in the binary and the library deploy jar
# at run time, and in :java_helper while scalac expands the macro. scalac gets
# the Scala jars of a macro before instrumentation, and Bazel instruments the
# Java jars.
coverage_test(
    name = "coverage_with_macro_binary_and_deploy_jar_test",
    expected_line = "SF:test/coverage_jacoco_runtime/User.scala",
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
    deps = [":java_helper"],
)

scala_test(
    name = "test",
    srcs = ["JacocoRuntimeTest.scala"],
    data = [
        ":bin",
        ":library_with_main_deploy.jar",
    ],
    deps = [":user"],
)

scala_binary(
    name = "bin",
    srcs = ["Main.scala"],
    main_class = "coverage_jacoco_runtime.Main",
    deps = [":helper"],
)

scala_library(
    name = "library_with_main",
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
    deps = [":java_helper"],
)

java_library(
    name = "java_helper",
    srcs = ["JavaHelper.java"],
)

scala_library(
    name = "helper",
    srcs = ["Helper.scala"],
)
