load("@rules_shell//shell:sh_test.bzl", "sh_test")

# test_cross_build is a separate Bazel module (its own MODULE.bazel/WORKSPACE,
# local_path_override'd onto this checkout) excluded from this repo's own
# package tree by .bazelignore per
# https://github.com/bazelbuild/bazel/issues/22208, so this package cannot sit
# inside it, and a label inside it cannot be passed to the
# expect_build_failure.bzl macros (which build a label in this same
# workspace). These tests instead drive a nested `bazel` from inside that
# module directly; see run_test.sh.
_NESTED_BAZEL_DATA = [
    "//:MODULE.bazel",
    "//test/expect_build_failure:nested_bazel.sh",
    # The select-based per-scala_version dep providers default_2x_build_test
    # verifies; listing it re-keys that test when the fix changes.
    "//scala:toolchains_repo.bzl",
]

_NESTED_BAZEL_TAGS = [
    "local",
    "no-release",
    "requires-network",
    "exclusive",
]

sh_test(
    name = "test_test",
    size = "large",
    srcs = ["run_test.sh"],
    args = [
        "test",
        "//...",
    ],
    data = _NESTED_BAZEL_DATA,
    tags = _NESTED_BAZEL_TAGS,
)

# Verifies cross-major-version compilation when the default is Scala 2.x and
# the targets use scala_version to select Scala 3.x. Without the select-based
# common_toolchain_deps fix, the reporter java_library compiles Scala 3
# sources against Scala 2 compiler JARs (wrong toolchain resolved in exec
# config), failing with "symbol not found dotty.tools.dotc.*".
#
# since_3_1 is the target that exercises the fix (default 2.x -> target 3.x).
# scala_2_13 and scala_2_12 are sanity checks for same-major cross-minor.
sh_test(
    name = "default_2x_build_test",
    size = "large",
    srcs = ["run_test.sh"],
    args = [
        "build",
        "--repo_env=SCALA_VERSION=2.13.18",
        "//version_specific:since_3_1",
        "//version_specific:scala_2_13",
        "//version_specific:scala_2_12",
    ],
    data = _NESTED_BAZEL_DATA,
    tags = _NESTED_BAZEL_TAGS,
)
