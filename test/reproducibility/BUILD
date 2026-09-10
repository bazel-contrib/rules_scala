load("@rules_shell//shell:sh_test.bzl", "sh_test")

# Bazel has no native "run bazel twice and diff the outputs" rule, and unlike
# expect_build_failure.bzl's macros this test can never be fingerprint-cached
# (its whole point is a clean-from-scratch build, twice), so it can't reuse
# those macros either. No fingerprint of the real sources under test is
# declared, so "external" disables test-result caching -- otherwise a stale
# cached PASS could survive a change that makes the build non-deterministic.
# "skip-toolchain-sweep": this test doesn't forward the outer build's
# --extra_toolchains to its nested builds, so test_rules_scala.sh's
# toolchain-sweep re-runs would just repeat the same ~14 minute build for no
# reason. Never exercised on Windows before (the old shell test only had
# linux/macos CI tasks) and this test's MSYS2 behavior (its own --disk_cache,
# mktemp, xargs -P5, md5sum) is unverified there, hence target_compatible_with.
sh_test(
    name = "build_is_identical_test",
    # Two full from-scratch builds of test/... plus the coverage packages,
    # with no caching possible by design -- measured at up to ~14 minutes on
    # the macOS CI runner. Not part of expect_build_failure.bzl's shared
    # lane pool: it's an order of magnitude heavier than the other nested
    # tests there and would dominate whichever lane it hashed into.
    size = "enormous",
    srcs = ["build_is_identical_test.sh"],
    data = [
        "//:MODULE.bazel",
        "//test/expect_build_failure:nested_bazel.sh",
    ],
    tags = [
        "exclusive",
        "external",
        "local",
        "no-release",
        "requires-network",
        "skip-toolchain-sweep",
    ],
    target_compatible_with = select({
        "@platforms//os:windows": ["@platforms//:incompatible"],
        "//conditions:default": [],
    }),
)
