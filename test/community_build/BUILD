# See README.md in this directory for what these are and how to run one.
#
# scala_version below must match MODULE.bazel's consumer(...) pin -- can't
# load() it instead, that would fetch the repo just to load this package.
load(":downstream_test.bzl", "downstream_test")
load(":source_fingerprint.bzl", "exposed_top_level_dirs_test")

exports_files(["downstream_test_driver.sh", "dicer_protobuf_version.patch"])

exposed_top_level_dirs_test(name = "exposed_top_level_dirs_test")

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
# macOS-incompatible: unreliable network for this repo's own macOS CI, not
# joern's fault. Tried excluding just kotlin2cpg/x2cpg (their Gradle
# download) and bumping maven.install()'s coursier-repin resolve_timeout
# 600s -> 1800s -- builds #6380 and #6382 both still timed out repinning
# @maven, right at whatever the ceiling was. Not chasing a third number;
# macOS drops joern_test entirely.
#
# extra_bazel_flags's --test_timeout bounds each nested test, not size
# (which bounds this whole sh_test action).
downstream_test(
    name = "joern_test",
    repo_name = "joern",
    scala_version = "3.7.4",
    extra_bazel_flags = "--test_timeout=60,1800,1800,3600",
    size = "enormous",
    target_compatible_with = ["@platforms//os:linux"],
    targets = [
        "//...",
        "-//joern-cli/frontends/php2cpg/...",
        "-//joern-cli/frontends/rust2cpg/...",
        "-//joern-cli/frontends/swiftsrc2cpg/...",
    ],
)

# dicer covers rules_scala's scala_proto/ScalaPB (gRPC) codegen path and
# Scala 2.12 (joern_test above is Scala 3, proto-free); that code runs
# throughout dicer/common, dicer/client, dicer/friend, wrappers/rpc, and
# beyond the 8 etcd-touching targets excluded below, which start a real
# etcd_release binary (`//bazel:etcd.bzl`) -- dicer's own etcd runtime
# setup -- and repeatedly time out talking to it in CI.
#
# algorithm_chaos_test is excluded below: it asserts a randomly-seeded
# statistical bound, flaky by construction.
#
# Linux-only: dicer's coursier resolve times out on this repo's macOS CI
# network (same failure as joern_test above), and the nested Bazelisk
# invocation needs %LocalAppData% for its home directory, unset on this
# repo's Windows CI.
#
# size = "enormous" for the same reason as joern_test above: dicer's nested
# test suite is large enough, with some tests minutes-long, to exceed this
# sh_test's own "large" (900s) default in total.
downstream_test(
    name = "dicer_test",
    repo_name = "dicer",
    scala_version = "2.12.21",
    size = "enormous",
    target_compatible_with = ["@platforms//os:linux"],
    targets = [
        "//...",
        "-//caching/util:etcd_suite",
        "-//dicer/assigner/algorithm:algorithm_chaos_test",
        "-//dicer/assigner:assigner_main_test",
        "-//dicer/assigner:etcd_preferred_assigner_driver_test",
        "-//dicer/assigner:etcd_preferred_assigner_integration_test",
        "-//dicer/assigner:etcd_preferred_assigner_store_test",
        "-//dicer/assigner:multiple_assigner_instances_test",
        "-//dicer/assigner:target_migration_integration_test",
        "-//dicer/common:etcd_bootstrapper_test",
    ],
)
