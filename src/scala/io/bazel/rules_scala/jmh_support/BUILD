load("//scala:scala.bzl", "scala_binary", "scala_library")

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
    # Under coverage, the benchmark jars are offline-instrumented and call the
    # JaCoCo runtime when the generator initializes their classes.
    jvm_flags = ["-Djacoco-agent.output=none"],
    main_class = "io.bazel.rules_scala.jmh_support.BenchmarkGenerator",
    visibility = ["//visibility:public"],
    runtime_deps = ["@bazel_tools//tools/jdk:JacocoCoverage"],
    deps = [":benchmark_generator_lib"],
)
