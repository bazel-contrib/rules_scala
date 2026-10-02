load("//scala:scala.bzl", "scala_binary")

# A simple scala_binary to run scaladoc.
# `bazel run` this target with "-help" as a param for usage text:
# bazel run -- "//src/scala/io/bazel/rules_scala/scaladoc_support:scaladoc_generator" -help
scala_binary(
    name = "scaladoc_generator",
    # Under coverage, macros in the documented targets' deps are
    # offline-instrumented and call the JaCoCo runtime while scaladoc expands them.
    jvm_flags = ["-Djacoco-agent.output=none"],
    main_class = "scala.tools.nsc.ScalaDoc",
    visibility = ["//visibility:public"],
    runtime_deps = [
        "@bazel_tools//tools/jdk:JacocoCoverage",
        "//scala/private/toolchain_deps:parser_combinators",
        "//scala/private/toolchain_deps:scala_compile_classpath",
        "//scala/private/toolchain_deps:scala_xml",
    ],
)
