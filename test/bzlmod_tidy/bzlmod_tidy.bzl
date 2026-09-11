"""Checks that `bazel mod tidy` leaves a repo MODULE.bazel file unchanged.

Each call runs `bazel mod tidy` against one repo-tracked MODULE.bazel file --
either the root repo or one of its standalone test fixtures that consumes
rules_scala through `local_path_override` -- and fails if that changes the
file. `bazel mod tidy` always writes its result straight to the target file,
so the test mutates the checkout on disk; a trap restores the original
content on exit regardless of outcome.

Tagged `external`: the result depends on this repo's whole module-extension
graph (every `bzlmod.bzl`-based extension, the registry, the lock file), too
much to name by hand as `data` the way the fingerprinted `expect_*_test`
family does for plain builds, so it always re-runs instead of caching.

Tagged `skip-toolchain-sweep`: test_rules_scala.sh re-runs `test/...` under a
few `--extra_toolchains` overrides to sweep Scala toolchain behavior. The
nested `bazel mod tidy` run here always uses its own fixed flags (see
nested_bazel.sh), so every sweep would repeat the identical check.
"""

load("@rules_shell//shell:sh_test.bzl", "sh_test")

_TAGS = [
    "exclusive",
    "external",
    "local",
    "requires-network",
    "skip-toolchain-sweep",
]

def bzlmod_tidy_test(name, module_dir):
    """A test that `bazel mod tidy` leaves `module_dir`'s MODULE.bazel unchanged.

    Args:
        name: the test target's name
        module_dir: repo-relative directory containing a MODULE.bazel file
            ("." for the repo root)
    """
    sh_test(
        name = name,
        size = "large",
        srcs = ["bzlmod_tidy_test.sh"],
        args = [module_dir],
        data = [
            "//:MODULE.bazel",
            "//test/expect_build_failure:nested_bazel.sh",
        ],
        tags = _TAGS,
    )
