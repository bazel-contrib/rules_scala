load("@bazel_skylib//:bzl_library.bzl", "bzl_library")
load("//scala/private:bzl_library.bzl", "bzl_libraries")

# For //tools:lint_check, which requires a `workspace` attribute. However, this
# can be any file, and `WORKSPACE` is going away one day. See:
# https://github.com/bazelbuild/buildtools/blob/v8.2.1/buildifier/runner.bash.template
exports_files(["MODULE.bazel"])

# For //test/scala_config:config_bzl_reflects_scala_version_test, which reads this
# repo rule's generated output; listing it in that test's `data` re-keys the test
# when the generation logic changes.
exports_files(["scala_config.bzl"])

# Declared inputs of nested `bazel` tests. The expect_* tests read the repo
# config, lockfile and Bazel version; the bzlmod macro tests also consume the
# latest-dependencies module through local_path_override.
exports_files([
    ".bazelrc",
    ".bazelversion",
    "MODULE.bazel.lock",
    "deps/latest/MODULE.bazel",
])

bzl_libraries(srcs = ["scala_config.bzl"])

# All `.bzl` files of rules_scala and the modules that they load.
bzl_library(
    name = "all_bzl",
    visibility = ["//visibility:public"],
    deps = [
        ":bzl_srcs",
        "//jmh:bzl_srcs",
        "//jmh/toolchain:bzl_srcs",
        "//junit:bzl_srcs",
        "//protoc:bzl_srcs",
        "//scala:bzl_srcs",
        "//scala/extensions:bzl_srcs",
        "//scala/private:bzl_srcs",
        "//scala/private/toolchain_deps:bzl_srcs",
        "//scala/scalafmt:bzl_srcs",
        "//scala/scalafmt/toolchain:bzl_srcs",
        "//scala/settings:bzl_srcs",
        "//scala/unstable:bzl_srcs",
        "//scala_proto:bzl_srcs",
        "//scala_proto/default:bzl_srcs",
        "//scala_proto/private:bzl_srcs",
        "//scalatest:bzl_srcs",
        "//specs2:bzl_srcs",
        "//src/java/io/bazel/rulesscala/scalac:bzl_srcs",
        "//testing:bzl_srcs",
        "//testing/toolchain:bzl_srcs",
        "//third_party/repositories:bzl_srcs",
        "//thrift:bzl_srcs",
        "//twitter_scrooge:bzl_srcs",
        "//twitter_scrooge/toolchain:bzl_srcs",
        "@bazel_skylib//:bzl_library",
        "@bazel_skylib//lib:dicts",
        "@bazel_skylib//lib:paths",
        "@bazel_skylib//rules:common_settings",
        "@bazel_tools//tools/build_defs/repo:cache.bzl",
        "@bazel_tools//tools/build_defs/repo:http.bzl",
        "@bazel_tools//tools/build_defs/repo:utils.bzl",
        "@com_google_protobuf//bazel/common:proto_common_bzl",
        "@com_google_protobuf//bazel/common:proto_info_bzl",
        "@platforms//host:constraints.bzl",
        "@rules_java//java:rules",
        "@rules_java//java/common",
        "@rules_java//java/private:proto_support",
        "@rules_java//toolchains:toolchain_utils",
        "@rules_scala_config//:config.bzl",
    ],
)
