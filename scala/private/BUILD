load("//scala/private:bzl_library.bzl", "bzl_library")
# Declared inputs for nested Bazel tests. Listing these files in those tests'
# `data` re-keys the tests when the logic changes.
exports_files([
    "macros/bzlmod.bzl",
    "macros/compiler_sources_integrity.bzl",
    "macros/scala_repositories.bzl",
])

# Exported so a test can declare them as inputs. //test/scalac_exec_group drives
# nested `bazel` invocations against the real source tree, which Bazel cannot
# see as a dependency of the test: without naming these, a regression here is
# served a cached PASS instead of re-running the test.
exports_files(
    [
        "rule_impls.bzl",
        "rules/scala_binary.bzl",
        "rules/scala_junit_test.bzl",
        "rules/scala_library.bzl",
        "rules/scala_repl.bzl",
        "rules/scala_test.bzl",
    ],
    visibility = ["//test:__subpackages__"],
)

# For //test/semanticdb, whose tests build a fixture using this phase; listing
# it in those tests' `data` re-keys the tests when the phase's logic changes.
# fixture_actions can't see this on its own: the fixture's only own action is
# a template expansion, which fingerprints by mnemonic and not by content.
exports_files(["phases/phase_semanticdb.bzl"])

bzl_library(
    name = "common",
    srcs = ["common.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//scala:jars_to_labels",
        "//scala:plusone",
        "//scala:providers",
        "@bazel_skylib//lib:paths",
        "@rules_java//java/common:common",
    ],
)

bzl_library(
    name = "common_attributes",
    srcs = ["common_attributes.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//scala:plusone",
        "@rules_java//java/common:common",
    ],
)

bzl_library(
    name = "common_outputs",
    srcs = ["common_outputs.bzl"],
    visibility = ["//:__subpackages__"],
)

bzl_library(
    name = "dependency",
    srcs = ["dependency.bzl"],
    visibility = ["//:__subpackages__"],
)

bzl_library(
    name = "jacoco_runtime",
    srcs = ["jacoco_runtime.bzl"],
    visibility = ["//:__subpackages__"],
)

bzl_library(
    name = "macros/bzlmod",
    srcs = ["macros/bzlmod.bzl"],
    visibility = ["//:__subpackages__"],
)

bzl_library(
    name = "macros/compiler_sources_integrity",
    srcs = ["macros/compiler_sources_integrity.bzl"],
    visibility = ["//:__subpackages__"],
)

bzl_library(
    name = "macros/repl_deps",
    srcs = ["macros/repl_deps.bzl"],
    visibility = ["//:__subpackages__"],
)

bzl_library(
    name = "macros/scala_repositories",
    srcs = ["macros/scala_repositories.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//:scala_config",
        "//scala:scala_cross_version",
        "//third_party/repositories:repositories",
        ":macros/compiler_sources_integrity",
        ":macros/repl_deps",
        "@bazel_tools//tools/build_defs/repo:cache.bzl",
        "@bazel_tools//tools/build_defs/repo:http.bzl",
        "@rules_scala_config//:config",
    ],
)

bzl_library(
    name = "macros/setup_scala_toolchain",
    srcs = ["macros/setup_scala_toolchain.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//scala:providers",
        "//scala:scala_cross_version",
        "//scala:scala_toolchain",
        ":macros/repl_deps",
        "@rules_scala_config//:config",
    ],
)

bzl_library(
    name = "macros/workspace_compat",
    srcs = ["macros/workspace_compat.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "@bazel_tools//tools/build_defs/repo:cache.bzl",
        "@bazel_tools//tools/build_defs/repo:http.bzl",
        "@bazel_tools//tools/build_defs/repo:utils.bzl",
    ],
)

bzl_library(
    name = "paths",
    srcs = ["paths.bzl"],
    visibility = ["//:__subpackages__"],
)

bzl_library(
    name = "phases/api",
    srcs = ["phases/api.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//scala:advanced_usage/providers",
        "@bazel_skylib//lib:dicts",
    ],
)

bzl_library(
    name = "phases/phase_collect_exports_jars",
    srcs = ["phases/phase_collect_exports_jars.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        ":common",
    ],
)

bzl_library(
    name = "phases/phase_collect_jars",
    srcs = ["phases/phase_collect_jars.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        ":common",
        "@rules_java//java/common:common",
    ],
)

bzl_library(
    name = "phases/phase_collect_srcjars",
    srcs = ["phases/phase_collect_srcjars.bzl"],
    visibility = ["//:__subpackages__"],
)

bzl_library(
    name = "phases/phase_compile",
    srcs = ["phases/phase_compile.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        ":common",
        ":paths",
        ":resources",
        ":rule_impls",
        "@rules_java//java/common:common",
    ],
)

bzl_library(
    name = "phases/phase_coverage",
    srcs = ["phases/phase_coverage.bzl"],
    visibility = ["//:__subpackages__"],
)

bzl_library(
    name = "phases/phase_coverage_runfiles",
    srcs = ["phases/phase_coverage_runfiles.bzl"],
    visibility = ["//:__subpackages__"],
)

bzl_library(
    name = "phases/phase_declare_executable",
    srcs = ["phases/phase_declare_executable.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        ":rule_impls",
    ],
)

bzl_library(
    name = "phases/phase_default_info",
    srcs = ["phases/phase_default_info.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        ":rule_impls",
    ],
)

bzl_library(
    name = "phases/phase_dependency",
    srcs = ["phases/phase_dependency.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        ":dependency",
        ":paths",
    ],
)

bzl_library(
    name = "phases/phase_java_wrapper",
    srcs = ["phases/phase_java_wrapper.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        ":rule_impls",
    ],
)

bzl_library(
    name = "phases/phase_jvm_flags",
    srcs = ["phases/phase_jvm_flags.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "@rules_java//java/common:common",
    ],
)

bzl_library(
    name = "phases/phase_merge_jars",
    srcs = ["phases/phase_merge_jars.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        ":rule_impls",
    ],
)

bzl_library(
    name = "phases/phase_runenvironmentinfo_provider",
    srcs = ["phases/phase_runenvironmentinfo_provider.bzl"],
    visibility = ["//:__subpackages__"],
)

bzl_library(
    name = "phases/phase_runfiles",
    srcs = ["phases/phase_runfiles.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        ":common",
    ],
)

bzl_library(
    name = "phases/phase_scalac_provider",
    srcs = ["phases/phase_scalac_provider.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//scala/private/toolchain_deps:toolchain_deps",
        "//scala:providers",
    ],
)

bzl_library(
    name = "phases/phase_scalacopts",
    srcs = ["phases/phase_scalacopts.bzl"],
    visibility = ["//:__subpackages__"],
)

bzl_library(
    name = "phases/phase_scalafmt",
    srcs = ["phases/phase_scalafmt.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        ":paths",
    ],
)

bzl_library(
    name = "phases/phase_scalainfo_provider",
    srcs = ["phases/phase_scalainfo_provider.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//scala:providers",
    ],
)

bzl_library(
    name = "phases/phase_semanticdb",
    srcs = ["phases/phase_semanticdb.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//scala/private/toolchain_deps:toolchain_deps",
        "//scala:semanticdb_provider",
        "@bazel_skylib//lib:paths",
        "@rules_java//java/common:common",
    ],
)

bzl_library(
    name = "phases/phase_write_executable",
    srcs = ["phases/phase_write_executable.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        ":common",
        ":macros/repl_deps",
        ":rule_impls",
    ],
)

bzl_library(
    name = "phases/phase_write_manifest",
    srcs = ["phases/phase_write_manifest.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        ":common",
    ],
)

bzl_library(
    name = "phases/phases",
    srcs = ["phases/phases.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        ":phases/api",
        ":phases/phase_collect_exports_jars",
        ":phases/phase_collect_jars",
        ":phases/phase_collect_srcjars",
        ":phases/phase_compile",
        ":phases/phase_coverage",
        ":phases/phase_coverage_runfiles",
        ":phases/phase_declare_executable",
        ":phases/phase_default_info",
        ":phases/phase_dependency",
        ":phases/phase_java_wrapper",
        ":phases/phase_jvm_flags",
        ":phases/phase_merge_jars",
        ":phases/phase_runenvironmentinfo_provider",
        ":phases/phase_runfiles",
        ":phases/phase_scalac_provider",
        ":phases/phase_scalacopts",
        ":phases/phase_scalafmt",
        ":phases/phase_scalainfo_provider",
        ":phases/phase_semanticdb",
        ":phases/phase_write_executable",
        ":phases/phase_write_manifest",
    ],
)

bzl_library(
    name = "resources",
    srcs = ["resources.bzl"],
    visibility = ["//:__subpackages__"],
)

bzl_library(
    name = "rule_impls",
    srcs = ["rule_impls.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        ":common",
        ":resources",
        "@bazel_skylib//lib:paths",
        "@rules_java//java/common:common",
        "@rules_java//toolchains:toolchain_utils",
    ],
)

bzl_library(
    name = "rules/scala_binary",
    srcs = ["rules/scala_binary.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//scala:providers",
        "//scala:scala_cross_version",
        ":common_attributes",
        ":common_outputs",
        ":phases/phases",
        "@bazel_skylib//lib:dicts",
        "@rules_java//java/common:common",
    ],
)

bzl_library(
    name = "rules/scala_doc",
    srcs = ["rules/scala_doc.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "@bazel_skylib//lib:paths",
        "//scala/private/toolchain_deps:toolchain_deps",
        "//scala:providers",
        "//scala:scala_cross_version",
        ":common",
        "@rules_java//java/common:common",
    ],
)

bzl_library(
    name = "rules/scala_junit_test",
    srcs = ["rules/scala_junit_test.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//scala:providers",
        "//scala:scala_cross_version",
        ":common_attributes",
        ":common_outputs",
        ":phases/phases",
        "@bazel_skylib//lib:dicts",
        "@rules_java//java/common:common",
    ],
)

bzl_library(
    name = "rules/scala_library",
    srcs = ["rules/scala_library.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//scala:providers",
        "//scala:scala_cross_version",
        ":common",
        ":common_attributes",
        ":common_outputs",
        ":phases/phases",
        "@bazel_skylib//lib:dicts",
        "@rules_java//java/common:common",
    ],
)

bzl_library(
    name = "rules/scala_repl",
    srcs = ["rules/scala_repl.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//scala:providers",
        "//scala:scala_cross_version",
        ":common_attributes",
        ":common_outputs",
        ":phases/phases",
        "@bazel_skylib//lib:dicts",
        "@rules_java//java/common:common",
    ],
)

bzl_library(
    name = "rules/scala_test",
    srcs = ["rules/scala_test.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//scala:providers",
        "//scala:scala_cross_version",
        ":common",
        ":common_attributes",
        ":common_outputs",
        ":phases/phases",
        "@bazel_skylib//lib:dicts",
        "@rules_java//java/common:common",
    ],
)

bzl_library(
    name = "toolchain_defaults",
    srcs = ["toolchain_defaults.bzl"],
    visibility = ["//:__subpackages__"],
    deps = [
        "//scala/scalafmt/toolchain:setup_scalafmt_toolchain",
        "//scala_proto:toolchains",
        "//twitter_scrooge/toolchain:toolchain",
    ],
)

bzl_library(
    name = "bzl_library",
    srcs = ["bzl_library.bzl"],
    visibility = ["//:__subpackages__"],
    deps = ["@bazel_skylib//:bzl_library"],
)
