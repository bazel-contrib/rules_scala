load("@rules_java//java:defs.bzl", "java_binary")

java_binary(
    name = "runner",
    srcs = ["ScaladocRunner.java"],
    main_class = "io.bazel.rulesscala.scaladoc.ScaladocRunner",
    visibility = ["//visibility:public"],
    # For some Scala 3 versions, `scala3-interfaces` comes only from
    # `scala_compile_classpath`.
    runtime_deps = [
        "//scala/private/toolchain_deps:scala_compile_classpath",
        "//scala/private/toolchain_deps:scala_doc_classpath",
    ],
)
