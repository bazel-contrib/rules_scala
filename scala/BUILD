load("//scala/private:bzl_library.bzl", "bzl_library")
load("@rules_java//java:defs.bzl", "java_import", "java_library")
load("@rules_scala_config//:config.bzl", "SCALA_VERSION")
load("//scala:scala_cross_version.bzl", "version_suffix")
load("//scala:scala_toolchain.bzl", "scala_toolchain")

# For //test/semanticdb, whose tests build a fixture using this provider;
# listing it in those tests' `data` re-keys the tests when its fields change.
exports_files(["semanticdb_provider.bzl"])

# For tests that run a nested module through these files, such as
# //test/cross_build_test and //test/toolchains/scala_disabled. When a test
# lists them in `data`, a change to them runs the test again.
exports_files([
    "toolchains.bzl",
    "toolchains_repo.bzl",
])

toolchain_type(
    name = "toolchain_type",
    visibility = ["//visibility:public"],
)

# Alias for backward compatibility
alias(
    name = "default_toolchain",
    actual = (
        "@rules_scala_toolchains//scala:toolchain" +
        version_suffix(SCALA_VERSION)
    ),
)

scala_toolchain(
    name = "unused_dependency_checker_error_toolchain_impl",
    dependency_tracking_method = "ast-plus",
    unused_dependency_checker_mode = "error",
)

scala_toolchain(
    name = "minimal_direct_source_deps_impl",
    dependency_mode = "plus-one",
    dependency_tracking_method = "ast",
    # Exclude the shadowing test package from strict-deps to allow classpath-order coverage without disabling strict-deps globally in CI runs.
    dependency_tracking_strict_deps_patterns = [
        "",  # keep default include
        "-//test/src/main/scala/scalarules/test/java_classpath_order",
    ],
    strict_deps_mode = "error",
    unused_dependency_checker_mode = "error",
)

[
    toolchain(
        name = tc,
        toolchain = tc + "_impl",
        toolchain_type = "//scala:toolchain_type",
        visibility = ["//visibility:public"],
    )
    for tc in [
        "unused_dependency_checker_error_toolchain",
        "minimal_direct_source_deps",
    ]
]

java_import(
    name = "bazel_test_runner_deploy",
    jars = ["@bazel_tools//tools/jdk:TestRunner_deploy.jar"],
    visibility = ["//visibility:public"],
)

java_library(
    name = "PlaceHolderClassToCreateEmptyJarForScalaImport",
    srcs = ["PlaceHolderClassToCreateEmptyJarForScalaImport.java"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "advanced_usage/providers",
    srcs = ["advanced_usage/providers.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "advanced_usage/scala",
    srcs = ["advanced_usage/scala.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private:rules/scala_binary",
        "//scala/private:rules/scala_junit_test",
        "//scala/private:rules/scala_library",
        "//scala/private:rules/scala_repl",
        "//scala/private:rules/scala_test",
    ],
)

bzl_library(
    name = "deps",
    srcs = ["deps.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private:macros/workspace_compat",
        "@bazel_tools//tools/build_defs/repo:cache.bzl",
        "@bazel_tools//tools/build_defs/repo:http.bzl",
        "@bazel_tools//tools/build_defs/repo:utils.bzl",
    ],
)

bzl_library(
    name = "jars_to_labels",
    srcs = ["jars_to_labels.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "latest_deps",
    srcs = ["latest_deps.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private:macros/workspace_compat",
        "@bazel_tools//tools/build_defs/repo:cache.bzl",
        "@bazel_tools//tools/build_defs/repo:http.bzl",
        "@bazel_tools//tools/build_defs/repo:utils.bzl",
    ],
)

bzl_library(
    name = "plusone",
    srcs = ["plusone.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "providers",
    srcs = ["providers.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "scala",
    srcs = ["scala.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private:macros/setup_scala_toolchain",
        "//scala/private:rules/scala_binary",
        "//scala/private:rules/scala_doc",
        "//scala/private:rules/scala_junit_test",
        "//scala/private:rules/scala_library",
        "//scala/private:rules/scala_repl",
        "//scala/private:rules/scala_test",
        "//specs2:specs2_junit",
    ],
)

bzl_library(
    name = "scala_cross_version",
    srcs = ["scala_cross_version.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "scala_cross_version_select",
    srcs = ["scala_cross_version_select.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        ":scala_cross_version",
        "@rules_scala_config//:config",
    ],
)

bzl_library(
    name = "scala_import",
    srcs = ["scala_import.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private:rule_impls",
        "//scala/settings:stamp_settings",
        ":jars_to_labels",
        "@rules_java//java/common:common",
    ],
)

bzl_library(
    name = "scala_maven_import_external",
    srcs = ["scala_maven_import_external.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "@bazel_tools//tools/build_defs/repo:utils.bzl",
    ],
)

bzl_library(
    name = "scala_toolchain",
    srcs = ["scala_toolchain.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        ":providers",
        "@bazel_skylib//rules:common_settings",
        "@rules_scala_config//:config",
    ],
)

bzl_library(
    name = "semanticdb_provider",
    srcs = ["semanticdb_provider.bzl"],
    visibility = ["//visibility:public"],
)

bzl_library(
    name = "toolchains",
    srcs = ["toolchains.bzl"],
    visibility = ["//visibility:public"],
    deps = [
        "//jmh/toolchain:toolchain",
        "//junit:junit",
        "//scala/private:macros/scala_repositories",
        "//scala/private:toolchain_defaults",
        "//scala/scalafmt:scalafmt_repositories",
        "//scala_proto/default:repositories",
        "//scalatest:scalatest",
        "//specs2:specs2_bzl",
        "//specs2:specs2_junit",
        "//third_party/repositories:repositories",
        "//twitter_scrooge/toolchain:toolchain",
        ":scala_cross_version",
        ":toolchains_repo",
        "@rules_scala_config//:config",
    ],
)

bzl_library(
    name = "toolchains_repo",
    srcs = ["toolchains_repo.bzl"],
    visibility = ["//visibility:public"],
)
