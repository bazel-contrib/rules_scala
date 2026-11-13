load("@rules_java//java:defs.bzl", "java_binary")
load("//scala/private:jacoco_runtime.bzl", "JACOCO_RUNTIME_DEPS", "JACOCO_RUNTIME_JVM_FLAGS")

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

java_binary(
    name = "scala2_runner",
    srcs = ["Scala2ScaladocRunner.java"],
    jvm_flags = JACOCO_RUNTIME_JVM_FLAGS,
    main_class = "io.bazel.rulesscala.scaladoc.Scala2ScaladocRunner",
    visibility = ["//visibility:public"],
    runtime_deps = JACOCO_RUNTIME_DEPS + [
        "//scala/private/toolchain_deps:parser_combinators",
        "//scala/private/toolchain_deps:scala_compile_classpath",
        "//scala/private/toolchain_deps:scala_xml",
    ],
)
