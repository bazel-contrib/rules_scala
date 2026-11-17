load("//scala/private:bzl_library.bzl", "bzl_library")
load("@rules_java//java:java_import.bzl", "java_import")
load("@rules_java//java:java_library.bzl", "java_library")

package(default_visibility = ["//visibility:public"])

java_import(
    name = "specs2",
    # `rules_java` 8.12.0 requires that `jars` not be empty. See #1741.
    jars = [":libempty.jar"],
    exports = [
        "//testing/toolchain:specs2_classpath",
    ],
    deps = [
        "//scala/private/toolchain_deps:scala_xml",
    ],
)

java_library(name = "empty")

bzl_library(
    name = "specs2_bzl",
    srcs = ["specs2.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "specs2_junit",
    srcs = ["specs2_junit.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        ":specs2_bzl",
    ],
)
