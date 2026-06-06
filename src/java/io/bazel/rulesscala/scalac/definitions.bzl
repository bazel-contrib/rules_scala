load("@rules_java//java:defs.bzl", "java_binary")
load("@rules_scala_config//:config.bzl", "ENABLE_COMPILER_DEPENDENCY_TRACKING")

DEFAULT_SCALAC_DEPS = [
    Label(dep)
    for dep in [
        "//scala/private/toolchain_deps:scala_compile_classpath",
        "//src/java/io/bazel/rulesscala/io_utils",
        "//src/java/io/bazel/rulesscala/jar",
        "//src/java/io/bazel/rulesscala/worker",
        "//src/protobuf/io/bazel/rules_scala:diagnostics_java_proto",
        "//src/java/io/bazel/rulesscala/scalac/compileoptions",
        "//src/java/io/bazel/rulesscala/scalac/reporter",
    ]
]

DEFAULT_SRCS = [
    Label("//src/java/io/bazel/rulesscala/scalac:scalac_files"),
]

# Keep -source/-target 1.8 for JDK 8 toolchains; -Xlint:-options silences the
# "source/target value 8 is obsolete" warning on newer JDKs.
_SCALAC_JAVACOPTS = [
    "-source",
    "1.8",
    "-target",
    "1.8",
    "-Xlint:-options",
]

def define_scalac(name = "scalac", srcs = DEFAULT_SRCS, deps = DEFAULT_SCALAC_DEPS):
    java_binary(
        name = name,
        srcs = srcs,
        javacopts = _SCALAC_JAVACOPTS,
        main_class = "io.bazel.rulesscala.scalac.ScalacWorker",
        visibility = ["//visibility:public"],
        deps = ([
            Label("//third_party/dependency_analyzer/src/main/io/bazel/rulesscala/dependencyanalyzer/compiler:dep_reporting_compiler"),
        ] if ENABLE_COMPILER_DEPENDENCY_TRACKING else []) + deps,
    )

def define_scalac_bootstrap(name = "scalac_bootstrap", srcs = DEFAULT_SRCS, deps = DEFAULT_SCALAC_DEPS):
    java_binary(
        name = name,
        srcs = srcs,
        javacopts = _SCALAC_JAVACOPTS,
        main_class = "io.bazel.rulesscala.scalac.ScalacWorker",
        visibility = ["//visibility:public"],
        deps = deps,
    )
