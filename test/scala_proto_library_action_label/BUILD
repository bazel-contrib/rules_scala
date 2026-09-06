load("@rules_shell//shell:sh_test.bzl", "sh_test")

# `third_party/test/proto` is `.bazelignore`d -- a self-contained bzlmod module
# invisible to this workspace's package graph -- so its files can't be listed
# in `data` to bust this test's cache the way `expect_build_failure.bzl` does
# for a same-workspace fixture. `external` is the tag Bazel gives a test whose
# correctness depends on state outside its declared inputs: it disables test
# result caching, so this always re-runs instead of replaying a stale result.
sh_test(
    name = "action_label_test",
    size = "large",
    srcs = ["action_label_test.sh"],
    data = [
        "//:MODULE.bazel",
        "//test/expect_build_failure:nested_bazel.sh",
    ],
    tags = [
        "external",
        "local",
        "requires-network",
    ],
)
