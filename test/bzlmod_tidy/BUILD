load("@rules_shell//shell:sh_test.bzl", "sh_test")
load(":bzlmod_tidy.bzl", "bzlmod_tidy_test")

# Every repo-tracked MODULE.bazel file's directory ("." for the root), kept in
# sync with `git ls-files '**MODULE.bazel'` by :all_module_bazel_files_covered_test.
MODULE_DIRS = [
    ".",
    "deps/latest",
    "dt_patches/compiler_sources",
    "dt_patches/test_dt_patches",
    "dt_patches/test_dt_patches_user_srcjar",
    "examples/crossbuild",
    "examples/overridden_artifacts",
    "examples/scala3",
    "examples/semanticdb",
    "examples/testing/multi_frameworks_toolchain",
    "examples/testing/scalatest_repositories",
    "examples/testing/specs2_junit_repositories",
    "examples/twitter_scrooge",
    "test/compiler_sources_integrity",
    "test/proto_cross_repo_boundary/repo",
    "test_cross_build",
    "third_party/test/example_external_workspace",
    "third_party/test/new_local_repo",
    "third_party/test/proto",
]

[
    bzlmod_tidy_test(
        name = ("root" if module_dir == "." else module_dir.replace("/", "_")) + "_bzlmod_tidy_test",
        module_dir = module_dir,
    )
    for module_dir in MODULE_DIRS
]

sh_test(
    name = "all_module_bazel_files_covered_test",
    size = "small",
    srcs = ["all_module_bazel_files_covered_test.sh"],
    args = MODULE_DIRS,
    data = [
        "//:MODULE.bazel",
        "//test/expect_build_failure:nested_bazel.sh",
    ],
    # Needs the `.git` metadata to run `git ls-files`, present only in the
    # checkout on disk that nested_bazel_setup points at. Tagged `external`
    # so it always re-runs: the git index sits outside Bazel's
    # declared-input tracking, so a newly tracked MODULE.bazel would
    # otherwise leave a cached pass standing. `skip-toolchain-sweep`: a
    # plain git-tracked-files comparison, invariant across
    # test_rules_scala.sh's --extra_toolchains sweeps.
    tags = ["external", "local", "skip-toolchain-sweep"],
)
