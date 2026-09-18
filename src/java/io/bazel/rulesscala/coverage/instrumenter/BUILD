load("@rules_java//java:defs.bzl", "java_binary", "java_library", "java_test")

java_library(
    name = "instrumenter_lib",
    srcs = [
        "//src/java/io/bazel/rulesscala/coverage/instrumenter:instrumenter_files",
    ],
    javacopts = [
        "-source 1.8",
        "-target 1.8",
    ],
    deps = [
        "//src/java/io/bazel/rulesscala/io_utils",
        "//src/java/io/bazel/rulesscala/jar",
        "//src/java/io/bazel/rulesscala/worker",
        "@bazel_tools//tools/jdk:JacocoCoverage",
    ],
)

java_binary(
    name = "instrumenter",
    main_class = "io.bazel.rulesscala.coverage.instrumenter.JacocoInstrumenter",
    visibility = ["//visibility:public"],
    runtime_deps = [":instrumenter_lib"],
)

java_test(
    name = "JacocoInstrumenterTest",
    srcs = ["JacocoInstrumenterTest.java"],
    test_class = "io.bazel.rulesscala.coverage.instrumenter.JacocoInstrumenterTest",
    deps = [":instrumenter_lib"],
)

filegroup(
    name = "instrumenter_files",
    srcs = [
        "JacocoInstrumenter.java",
    ],
    visibility = ["//visibility:public"],
)
