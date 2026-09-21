load("@rules_shell//shell:sh_test.bzl", "sh_test")

# See run_test.sh for why building these standalone is a separate check.
# `third_party/test/proto`, `test/compiler_sources_integrity`, and
# `test_cross_build` have their own such test elsewhere and are excluded.
MODULE_DIRS = [
    "test/proto_cross_repo_boundary/repo",
    "third_party/test/example_external_workspace",
    "third_party/test/new_local_repo",
]

_NESTED_BAZEL_DATA = [
    "//:MODULE.bazel",
    "//test/expect_build_failure:nested_bazel.sh",
]

# `external`: forces a fresh run every time, since these modules' files
# can't be listed as `data` to invalidate the cache the normal way. See
# test/scala_proto_library_action_label/BUILD.
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
