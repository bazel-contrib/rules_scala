# See README.md in this directory for what these are and how to run one.
#
# scala_version below must match MODULE.bazel's consumer(...) pin -- can't
# load() it instead, that would fetch the repo just to load this package.
load(":downstream_test.bzl", "downstream_test")
load(":source_fingerprint.bzl", "exposed_top_level_dirs_test")

exports_files([
    "downstream_test_driver.sh",
    "dicer_protobuf_version.patch",
    "joern_jssrc2cpg_smoke.patch",
])

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
#
# test_filter selects jssrc2cpg's own SmokeSuite (see
# joern_jssrc2cpg_smoke.patch): jssrc2cpg is this test's single most
# expensive target (~750-820s of the ~1050-1200s this whole test costs once
# the nested build itself is warm), and its ~11k lines of test sources are
# ~99% Joern's own JS/TS semantic correctness -- an assertion about Joern's
# own correctness. The patch adds one new
# file aggregating a handful of existing test classes (AST, CFG, dataflow,
# type-recovery, plus the closest things to an integration smoke test: a
# real AstGenRunner file-parse and a JVM HTTP server + full classpath) into
# one suite; test_filter selects just that suite, so jssrc2cpg's test
# sources still compile in full (real Scala 3 compile workload against the
# toolchain under test) but only the smoke subset executes: measured
# 748-820s -> 165-215s.
downstream_test(
    name = "joern_test",
    size = "enormous",
    extra_bazel_flags = "--test_timeout=60,1800,1800,3600",
    filtered_targets = ["//joern-cli/frontends/jssrc2cpg:tests"],
    patches = ["//test/community_build:joern_jssrc2cpg_smoke.patch"],
    repo_name = "joern",
    scala_version = "3.7.4",
    target_compatible_with = ["@platforms//os:linux"],
    targets = [
        "//...",
        "-//joern-cli/frontends/php2cpg/...",
        "-//joern-cli/frontends/rust2cpg/...",
        "-//joern-cli/frontends/swiftsrc2cpg/...",
        "-//joern-cli/frontends/jssrc2cpg/...",
    ],
    test_filter = "io.joern.jssrc2cpg.SmokeSuite",
)

# dicer_test's job: exercise rules_scala's scala_proto/ScalaPB (gRPC)
# codegen and Scala 2.12 support.
#
# The 8 targets excluded below start a real etcd binary. That binary is
# what repeatedly times out in CI.
#
# algorithm_chaos_test is excluded below: it asserts a randomly-seeded
# statistical bound, flaky by construction.
#
# Linux-only: this repo's macOS CI hits a coursier network timeout running
# dicer_test, and its Windows CI is missing %LocalAppData%, needed by the
# nested Bazelisk invocation.
#
# size = "enormous" for the same reason as joern_test above: dicer's nested
# test suite is large enough, with some tests minutes-long, to exceed this
# sh_test's own "large" (900s) default in total.
downstream_test(
    name = "dicer_test",
    size = "enormous",
    patches = ["//test/community_build:dicer_protobuf_version.patch"],
    repo_name = "dicer",
    scala_version = "2.12.21",
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
