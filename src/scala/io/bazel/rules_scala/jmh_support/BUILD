load("//scala:scala.bzl", "scala_binary", "scala_library")
load("//scala/private:jacoco_runtime.bzl", "JACOCO_RUNTIME_DEPS", "JACOCO_RUNTIME_JVM_FLAGS")

scala_library(
    name = "benchmark_generator_lib",
    srcs = ["BenchmarkGenerator.scala"],
    visibility = ["//visibility:public"],
    runtime_deps = [
        "//jmh:benchmark_generator_runtime",
    ],
    deps = [
        "//jmh:benchmark_generator",
        "//scala/private/source_compat",
    ],
)

scala_binary(
    name = "benchmark_generator",
    jvm_flags = JACOCO_RUNTIME_JVM_FLAGS,
    main_class = "io.bazel.rules_scala.jmh_support.BenchmarkGenerator",
    visibility = ["//visibility:public"],
    runtime_deps = JACOCO_RUNTIME_DEPS,
    deps = [":benchmark_generator_lib"],
)
