load("@rules_java//java:defs.bzl", "java_library", "java_test")

java_library(
    name = "compileoptions",
    srcs = ["CompileOptions.java"],
    visibility = ["//visibility:public"],
    deps = ["//scala/private/toolchain_deps:scala_compile_classpath"],
)

java_test(
    name = "CompileOptionsTest",
    srcs = ["CompileOptionsTest.java"],
    test_class = "io.bazel.rulesscala.scalac.compileoptions.CompileOptionsTest",
    deps = [":compileoptions"],
)

filegroup(
    name = "package_sources",
    srcs = glob(["**/*"], allow_empty = True),
    visibility = ["//test/community_build:__pkg__"],
)
