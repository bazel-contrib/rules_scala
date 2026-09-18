load("@rules_shell//shell:sh_test.bzl", "sh_test")

# Modules that are ONLY exercised as a root `dev_dependency` today, never as
# their own build root -- see run_test.sh for why that distinction matters.
# `third_party/test/proto`, `test/compiler_sources_integrity`, and
# `test_cross_build` are excluded: each already has its own nested-bazel test
# elsewhere (test/scala_proto_library_action_label, test/compiler_sources_integrity_test,
# test/cross_build_test) that builds it as its own root.
MODULE_DIRS = [
    "test/proto_cross_repo_boundary/repo",
    "third_party/test/example_external_workspace",
    "third_party/test/new_local_repo",
]

_NESTED_BAZEL_DATA = [
    "//:MODULE.bazel",
    "//test/expect_build_failure:nested_bazel.sh",
]

# `external`: each module in MODULE_DIRS is its own bzlmod module, so its
# files can't be listed in `data` to bust this test's cache the way
# `expect_build_failure.bzl` does for a same-workspace fixture. `external`
# disables test result caching, so this always re-runs instead of replaying a
# stale result. See test/scala_proto_library_action_label/BUILD.
_NESTED_BAZEL_TAGS = [
    "exclusive",
    "external",
    "local",
    "no-release",
    "requires-network",
    "skip-toolchain-sweep",
]

[
    sh_test(
        name = module_dir.replace("/", "_") + "_standalone_root_build_test",
        size = "large",
        srcs = ["run_test.sh"],
        args = [module_dir],
        data = _NESTED_BAZEL_DATA,
        tags = _NESTED_BAZEL_TAGS,
    )
    for module_dir in MODULE_DIRS
]
