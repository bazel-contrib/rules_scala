load("//scala:scala.bzl", "scala_binary")
load("//scala/private:jacoco_runtime.bzl", "JACOCO_RUNTIME_DEPS", "JACOCO_RUNTIME_JVM_FLAGS")

# A simple scala_binary to run scaladoc.
# `bazel run` this target with "-help" as a param for usage text:
# bazel run -- "//src/scala/io/bazel/rules_scala/scaladoc_support:scaladoc_generator" -help
scala_binary(
    name = "scaladoc_generator",
    jvm_flags = JACOCO_RUNTIME_JVM_FLAGS,
    main_class = "scala.tools.nsc.ScalaDoc",
    visibility = ["//visibility:public"],
    runtime_deps = JACOCO_RUNTIME_DEPS + [
        "//scala/private/toolchain_deps:parser_combinators",
        "//scala/private/toolchain_deps:scala_compile_classpath",
        "//scala/private/toolchain_deps:scala_xml",
    ],
)
