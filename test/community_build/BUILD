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
    "joern_x2cpg_smoke.patch",
    "joern_rubysrc2cpg_smoke.patch",
    "joern_kotlin2cpg_smoke.patch",
    "joern_javasrc2cpg_smoke.patch",
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
# test_filter selects each filtered target's own smoke suite (see the
# joern_*_smoke.patch files for what each one wraps and why). It becomes
# ScalaTest's own `-s <value>` (see `io.bazel.rulesscala.scala_test.Runner`),
# one exact class name shared across every filtered_targets entry in this
# single nested `bazel test` invocation -- so every filtered target's suite
# needs the identical fully-qualified class name (io.joern.smoke.SmokeSuite)
# for that one value to resolve in each one's own classpath. Full test
# source still compiles for all of them; only the smoke subset executes.
# Test-execution time, measured in a Linux container:
#   jssrc2cpg:   ~800s -> ~165s
#   x2cpg:       ~105s -> ~3s
#   rubysrc2cpg: ~55s  -> ~7s
#   kotlin2cpg:  ~40s  -> ~3s
#   javasrc2cpg: ~25s  -> ~6s
#
# c2cpg, pysrc2cpg, semanticcpg, and dataflowengineoss (each under 11s) keep
# running unfiltered: too cheap to bother.
downstream_test(
    name = "joern_test",
    size = "enormous",
    extra_bazel_flags = "--test_timeout=60,1800,1800,3600",
    filtered_targets = [
        "//joern-cli/frontends/jssrc2cpg:tests",
        "//joern-cli/frontends/x2cpg:tests",
        "//joern-cli/frontends/rubysrc2cpg:tests",
        "//joern-cli/frontends/kotlin2cpg:tests",
        "//joern-cli/frontends/javasrc2cpg:tests",
    ],
    patches = [
        "//test/community_build:joern_jssrc2cpg_smoke.patch",
        "//test/community_build:joern_x2cpg_smoke.patch",
        "//test/community_build:joern_rubysrc2cpg_smoke.patch",
        "//test/community_build:joern_kotlin2cpg_smoke.patch",
        "//test/community_build:joern_javasrc2cpg_smoke.patch",
    ],
    repo_name = "joern",
    scala_version = "3.7.4",
    target_compatible_with = ["@platforms//os:linux"],
    targets = [
        "//...",
        "-//joern-cli/frontends/php2cpg/...",
        "-//joern-cli/frontends/rust2cpg/...",
        "-//joern-cli/frontends/swiftsrc2cpg/...",
        "-//joern-cli/frontends/jssrc2cpg/...",
        "-//joern-cli/frontends/x2cpg/...",
        "-//joern-cli/frontends/rubysrc2cpg/...",
        "-//joern-cli/frontends/kotlin2cpg/...",
        "-//joern-cli/frontends/javasrc2cpg/...",
    ],
    test_filter = "io.joern.smoke.SmokeSuite",
)

# dicer_test's job: exercise rules_scala's scala_proto/ScalaPB (gRPC)
# codegen and Scala 2.12 support.
#
# Linux-only: this repo's macOS CI hits a coursier network timeout running
# dicer_test, and its Windows CI is missing %LocalAppData%, needed by the
# nested Bazelisk invocation.
#
# size = "enormous" for the same reason as joern_test above: dicer's nested
# test suite is large enough, with some tests minutes-long, to exceed this
# sh_test's own "large" (900s) default in total.
#
# smoke_test_targets: dicer's other ~150 test targets assert dicer's own
# business logic; these two are the actual runtime check for
# scala_proto/ScalaPB codegen, round-tripping real generated messages
# (`toProto`/`fromProto`). gRPC service/stub code keeps compile-only
# coverage, same as everything else in `targets` -- which needs no
# exclusions any more: a real etcd binary starting (8 targets across
# //caching/util and //dicer/assigner, //dicer/common), a flaky statistical
# assertion (algorithm_chaos_test), and a tight test timeout under load
# (assignment_generator_test) were all test-execution problems, moot once
# a target only builds.
downstream_test(
    name = "dicer_test",
    size = "enormous",
    patches = ["//test/community_build:dicer_protobuf_version.patch"],
    repo_name = "dicer",
    scala_version = "2.12.21",
    smoke_test_targets = [
        "//dicer/common:assignment_test",
        "//dicer/common:diff_assignment_test",
    ],
    target_compatible_with = ["@platforms//os:linux"],
    targets = ["//..."],
)
