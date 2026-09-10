load("@rules_shell//shell:sh_test.bzl", "sh_test")

# Bazel has no native "run bazel twice and diff the outputs" rule, and unlike
# expect_build_failure.bzl's macros this test can never be fingerprint-cached
# (its whole point is a clean-from-scratch build, twice), so it can't reuse
# those macros either.
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
        "local",
        "no-release",
        "requires-network",
    ],
)
