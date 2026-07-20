# See README.md in this directory for what these are and how to run one.
load(":downstream_test.bzl", "downstream_test")
load("@joern//_bazel_native_marker:version.bzl", JOERN_SCALA_VERSION = "SCALA_VERSION")
load("@dicer//_bazel_native_marker:version.bzl", DICER_SCALA_VERSION = "SCALA_VERSION")

exports_files(["downstream_test_driver.sh"])

# joern is Scala-3-only and uses only scala_library/scala_test throughout its
# tree.
#
# The following are excluded because each needs something this environment
# doesn't have -- none of it is rules_scala's concern:
#   - php2cpg needs a real `php` binary on PATH.
#   - rust2cpg needs `cargo`/`rustc` on PATH.
#   - swiftsrc2cpg times out (its own native toolchain setup, not investigated).
downstream_test(
    name = "joern_test",
    repo_name = "joern",
    scala_version = JOERN_SCALA_VERSION,
    targets = [
        "//...",
        "-//joern-cli/frontends/php2cpg/...",
        "-//joern-cli/frontends/rust2cpg/...",
        "-//joern-cli/frontends/swiftsrc2cpg/...",
    ],
)

# dicer exercises rules_scala's scala_proto/ScalaPB (gRPC) codegen path and
# pins Scala 2.12 -- both are things joern's Scala-3-only, proto-free tree
# never touches, so this is a second, non-redundant consumer rather than a
# duplicate of joern_test.
#
# Excluded: `caching/util:etcd_suite`, `dicer/common:etcd_bootstrapper_test`,
# and everything under `dicer/assigner/...`. All of them spin up a downloaded
# `etcd_release` binary (`//bazel:etcd.bzl`) that exits with code 126 on this
# machine -- looks like a missing darwin-arm64 build of that specific etcd
# release, an environment limitation, not rules_scala's concern. Plausibly
# fine on a Linux CI runner; worth re-checking there rather than assuming
# this exclusion holds everywhere.
downstream_test(
    name = "dicer_test",
    repo_name = "dicer",
    scala_version = DICER_SCALA_VERSION,
    targets = [
        "//...",
        "-//dicer/assigner/...",
        "-//caching/util:etcd_suite",
        "-//dicer/common:etcd_bootstrapper_test",
    ],
)
