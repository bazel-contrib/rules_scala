# See README.md in this directory for what these are and how to run one.
#
# scala_version below duplicates the pin in the root MODULE.bazel's
# downstream_consumers.consumer(...) call for the same repo_name, kept in
# sync by hand -- it can't be load()-ed from the fetched repo instead, since
# a load() on an external-repo label forces Bazel to fetch that repo just to
# *load this package*, regardless of the `manual` tag on the targets below.
load(":downstream_test.bzl", "downstream_test")

exports_files(["downstream_test_driver.sh", "dicer_protobuf_version.patch"])

# joern is Scala-3-only and uses only scala_library/scala_test throughout its
# tree.
#
# The following are excluded because each needs something this environment
# doesn't have -- none of it is rules_scala's concern:
#   - php2cpg needs a real `php` binary on PATH.
#   - rust2cpg needs `cargo`/`rustc` on PATH.
#   - swiftsrc2cpg times out (its own native toolchain setup, not investigated).
#
# Windows-incompatible: the driver copies joern's fetched repo out with
# `cp -R`, and joern's own tree contains symlinks (CLI wrapper scripts,
# frontend binaries) that Windows can't create without elevated
# privileges -- fails with "cannot create symbolic link ... No such file
# or directory" for each one.
#
# Two independent timeouts are in play here: extra_bazel_flags's
# --test_timeout bounds each individual test inside joern's own nested
# bazel invocation; size bounds this whole sh_test action (git fetch plus
# all 9 nested frontends combined). Under CI contention, jssrc2cpg
# (medium, 300s default) and x2cpg/kotlin2cpg (large, 900s default) all
# run close to their own bucket, so bump moderate and long together
# rather than touch joern's own test sizes. size = "enormous" covers the
# outer action's total separately.
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
    ],
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
