load("@rules_java//java:defs.bzl", "java_library")
load("//scala:scala.bzl", "scala_library")

package(default_visibility = ["//visibility:public"])

scala_library(
    name = "transitive_external_dependency_user",
    testonly = True,
    srcs = [
        "A.scala",
    ],
    deps = ["external_dependency_user"],
)

scala_library(
    name = "external_dependency_user",
    testonly = True,
    srcs = [
        "B.scala",
    ],
    deps = ["@rules_scala_test_maven//:com_google_guava_guava"],
)

# tests if external jars are stamped with a correct label
java_library(
    name = "java_lib_with_unused_external_dep",
    testonly = True,
    srcs = ["Empty.java"],
    deps = ["@io_bazel_rules_scala_guava"],
)

java_library(
    name = "java_lib_with_a_transitive_external_dep",
    testonly = True,
    srcs = ["UsesExternalDep.java"],
    deps = [":java_lib_with_unused_external_dep"],
)
