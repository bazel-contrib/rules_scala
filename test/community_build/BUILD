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
# jssrc2cpg:tests is medium-sized (300s default) and runs close to that
# limit even on its own; contending with the rest of this repo's own test
# suite for CPU on the same CI machine pushes it over. Bump the moderate
# bucket rather than touch joern's own test size -- and this sh_test's own
# default ("large", 900s) with it, since the nested run (all 9 frontends,
# one now taking up to 900s alone) can exceed that in total.
#
# Linux-only: on macOS CI, x2cpg/kotlin2cpg/jssrc2cpg run right at this
# same 900s edge and flip between passing and TIMEOUT run to run --
# confirmed clean on linux (build #6360), never confirmed stable on macOS.
downstream_test(
    name = "joern_test",
    repo_name = "joern",
    scala_version = "3.7.4",
    extra_bazel_flags = "--test_timeout=60,900,900,3600",
    target_compatible_with = ["@platforms//os:linux"],
    timeout = "eternal",
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
# Unlike joern above, nothing is excluded here: `caching/util:etcd_suite`,
# `dicer/common:etcd_bootstrapper_test`, and `dicer/assigner/...` each need
# a downloaded `etcd_release` binary (`//bazel:etcd.bzl`) hardcoded to a
# linux-amd64 release -- confirmed passing clean on this repo's own
# linux-amd64 CI (build #6360). Linux-only for that reason: the etcd
# binary can't run at all on other architectures ("etcd exited with code
# 126", e.g. darwin-arm64).
#
# timeout = "eternal" for the same reason as joern_test above: 163 nested
# tests, several of them minutes-long, can exceed this sh_test's own default
# ("large", 900s) in total.
downstream_test(
    name = "dicer_test",
    repo_name = "dicer",
    scala_version = "2.12.21",
    target_compatible_with = ["@platforms//os:linux"],
    timeout = "eternal",
    targets = [
        "//...",
    ],
)
