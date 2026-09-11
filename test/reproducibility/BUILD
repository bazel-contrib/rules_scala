load("@rules_shell//shell:sh_test.bzl", "sh_test")

# Runs two from-scratch nested builds and diffs their jar hashes -- no
# built-in Bazel rule does that, and it can't be fingerprint-cached like
# expect_build_failure.bzl's macros, so it's a bespoke sh_test.
#
# manual: kept off any //... or test/... wildcard (including
# test_rules_scala.sh's toolchain sweep) since ~14 min per run on macOS CI
# would otherwise serialize into whichever job picked it up. Instead it's
# its own dedicated presubmit.yml task, run by naming this target directly.
# size=enormous: matches that ~14 min per-run cost.
# external: forces a fresh run every time instead of reusing a cached PASS,
# since re-executing the two builds is the only way this test can catch a
# build turning non-deterministic.
# target_compatible_with: limited to platforms where the original shell test
# actually ran; Windows is new ground for this script's MSYS2 behavior.
sh_test(
    name = "build_is_identical_test",
    size = "enormous",
    srcs = ["build_is_identical_test.sh"],
    data = [
        "//:MODULE.bazel",
        "//test/expect_build_failure:nested_bazel.sh",
    ],
    tags = [
        "external",
        "local",
        "manual",
        "no-release",
        "requires-network",
    ],
    target_compatible_with = select({
        "@platforms//os:windows": ["@platforms//:incompatible"],
        "//conditions:default": [],
    }),
)
