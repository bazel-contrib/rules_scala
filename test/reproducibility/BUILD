load("@rules_shell//shell:sh_test.bzl", "sh_test")

# Runs two from-scratch nested builds and diffs their jar hashes -- no
# built-in Bazel rule does that, and it can't be fingerprint-cached like
# expect_build_failure.bzl's macros, so it's a bespoke sh_test.
#
# size=enormous: ~14 min per run on macOS CI, not part of the shared 3-lane
# pool (an order of magnitude heavier, would dominate its lane).
# external: no fingerprint is declared, so without this a stale cached PASS
# could survive a build becoming non-deterministic.
# skip-toolchain-sweep: doesn't forward --extra_toolchains to its nested
# builds, so sweep re-runs would repeat the same build for nothing.
# target_compatible_with: never run on Windows before, MSYS2 behavior here
# is unverified.
sh_test(
    name = "build_is_identical_test",
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
