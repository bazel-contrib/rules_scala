# See README.md in this directory for what these are and how to run one.
#
# scala_version below duplicates the pin in the root MODULE.bazel's
# downstream_consumers.consumer(...) call for the same repo_name, kept in
# sync by hand -- it can't be load()-ed from the fetched repo instead, since
# a load() on an external-repo label forces Bazel to fetch that repo just to
# *load this package*, regardless of the `manual` tag on the targets below.
load(":downstream_test.bzl", "downstream_test")

exports_files(["downstream_test_driver.sh", "dicer_protobuf_version.patch", "joern_resolve_timeout.patch"])

# joern is Scala-3-only and uses only scala_library/scala_test throughout its
# tree.
#
# Excluded everywhere -- none of it is rules_scala's concern: php2cpg needs
# `php` on PATH, rust2cpg needs `cargo`/`rustc`, swiftsrc2cpg times out (own
# native toolchain, not investigated).
#
# Windows-incompatible: the driver's `cp -R` can't recreate joern's symlinks
# (CLI wrappers, frontend binaries) without elevated privileges.
#
# kotlin2cpg/x2cpg excluded on macOS only: their dependency-resolver-v2
# tests fetch a ~140MB Gradle distribution over the network, uncached
# between CI runs, and reliably time out on macOS CI (the same download
# takes ~8s on a fast connection -- it's the CI network, not CPU). Linux
# and Windows don't hit this.
#
# Two independent timeouts: extra_bazel_flags's --test_timeout bounds each
# nested test; size bounds this whole sh_test action. jssrc2cpg hit 1108s
# under CI contention in build #6372, so moderate is bumped past that.
# size = "enormous" covers the outer action separately.
downstream_test(
    name = "joern_test",
    repo_name = "joern",
    scala_version = "3.7.4",
    extra_bazel_flags = "--test_timeout=60,1800,1800,3600",
    size = "enormous",
    target_compatible_with = select({
        "@platforms//os:windows": ["@platforms//:incompatible"],
        "//conditions:default": [],
    }),
    targets = [
        "//...",
        "-//joern-cli/frontends/php2cpg/...",
        "-//joern-cli/frontends/rust2cpg/...",
        "-//joern-cli/frontends/swiftsrc2cpg/...",
    ] + select({
        "@platforms//os:macos": [
            "-//joern-cli/frontends/kotlin2cpg/...",
            "-//joern-cli/frontends/x2cpg/...",
        ],
        "//conditions:default": [],
    }),
)

# dicer covers rules_scala's scala_proto/ScalaPB (gRPC) codegen path and
# Scala 2.12 -- neither exercised by joern_test above (Scala 3, proto-free).
#
# Unlike joern above, nothing is excluded here: `caching/util:etcd_suite`,
# `dicer/common:etcd_bootstrapper_test`, and `dicer/assigner/...` each need
# a downloaded `etcd_release` binary (`//bazel:etcd.bzl`) hardcoded to a
# linux-amd64 release, so this is linux-only: the binary can't execute at
# all on other architectures ("etcd exited with code 126", e.g.
# darwin-arm64).
#
# size = "enormous" for the same reason as joern_test above: 163 nested
# tests, several of them minutes-long, can exceed this sh_test's own
# "large" (900s) default in total.
downstream_test(
    name = "dicer_test",
    repo_name = "dicer",
    scala_version = "2.12.21",
    size = "enormous",
    target_compatible_with = ["@platforms//os:linux"],
    targets = [
        "//...",
    ],
)
