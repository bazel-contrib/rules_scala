load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//third_party/repositories:scala_2_11.bzl", scala_2_11_version = "scala_version")
load("//third_party/repositories:scala_2_12.bzl", scala_2_12_version = "scala_version")
load("//third_party/repositories:scala_2_13.bzl", scala_2_13_version = "scala_version")
load("//third_party/repositories:scala_3_1.bzl", scala_3_1_version = "scala_version")
load("//third_party/repositories:scala_3_2.bzl", scala_3_2_version = "scala_version")
load("//third_party/repositories:scala_3_3.bzl", scala_3_3_version = "scala_version")
load("//third_party/repositories:scala_3_4.bzl", scala_3_4_version = "scala_version")
load("//third_party/repositories:scala_3_5.bzl", scala_3_5_version = "scala_version")
load("//third_party/repositories:scala_3_6.bzl", scala_3_6_version = "scala_version")
load("//third_party/repositories:scala_3_7.bzl", scala_3_7_version = "scala_version")
load("//third_party/repositories:scala_3_8.bzl", scala_3_8_version = "scala_version")

# test/compiler_sources_integrity is a separate Bazel module (its own
# MODULE.bazel/WORKSPACE, local_path_override'd onto this checkout) excluded
# from this repo's own package tree by .bazelignore per
# https://github.com/bazelbuild/bazel/issues/22208, so this package cannot sit
# inside it, and a label inside it cannot be passed to the
# expect_build_failure.bzl macros (which build a label in this same
# workspace). These tests instead drive a nested `bazel build` from inside
# that module directly; see success_test.sh/failure_test.sh.
#
# The logic under test lives in these two files; listing them re-keys every
# test here when that logic changes.
_NESTED_BAZEL_DATA = [
    "//:MODULE.bazel",
    "//test/expect_build_failure:nested_bazel.sh",
    "//scala/private:macros/compiler_sources_integrity.bzl",
    "//scala/private:macros/scala_repositories.bzl",
]

_NESTED_BAZEL_TAGS = [
    "local",
    "requires-network",
    "exclusive",
]

# Mirrors scala/private/macros/compiler_sources_integrity.bzl's URL_PREFIX and
# URL_SUFFIX_BY_MAJOR_VERSION (a bzl-visibility-private module this package
# cannot load).
_REPO_URL_PREFIX = "https://repo1.maven.org/maven2/org/scala-lang/"

_SCALA_2_URL_SUFFIX = "scala-compiler/{version}/scala-compiler-{version}-sources.jar"

_SCALA_3_URL_SUFFIX = "scala3-compiler_3/{version}/scala3-compiler_3-{version}-sources.jar"

# sh_test's `args` are shell-tokenized, so any element containing whitespace
# (unlike a bare version number or URL) must be single-quoted to survive as
# one arg -- the same mechanism _nested_bazel_test uses for a spacey
# bazel_args/env value.
_FAILED_MSG = "'No compiler source jar integrity data exists'"

sh_test(
    name = "default_version_no_warning_test",
    size = "large",
    srcs = ["success_test.sh"],
    data = _NESTED_BAZEL_DATA,
    tags = _NESTED_BAZEL_TAGS,
)

# One target per Scala version configured in third_party/repositories: the
# newest patch release tracked for each supported major.minor line. Each also
# lists its own version file in `data`: bumping a coordinate must re-run only
# that version's test.
#
# This list is manual, not derived from a glob: a `load()` statement is
# static in Starlark, so it can't be generated from a glob() over
# third_party/repositories/scala_*.bzl. Adding a new major.minor line needs a
# `load()` above and an entry below.
[
    sh_test(
        name = "latest_version_%s_no_warning_test" % scala_version.replace(".", "_"),
        size = "large",
        srcs = ["success_test.sh"],
        args = [
            "--scala-version",
            scala_version,
        ],
        data = _NESTED_BAZEL_DATA + ["//third_party/repositories:%s.bzl" % bzl_name],
        tags = _NESTED_BAZEL_TAGS,
    )
    for bzl_name, scala_version in [
        ("scala_2_11", scala_2_11_version),
        ("scala_2_12", scala_2_12_version),
        ("scala_2_13", scala_2_13_version),
        ("scala_3_1", scala_3_1_version),
        ("scala_3_2", scala_3_2_version),
        ("scala_3_3", scala_3_3_version),
        ("scala_3_4", scala_3_4_version),
        ("scala_3_5", scala_3_5_version),
        ("scala_3_6", scala_3_6_version),
        ("scala_3_7", scala_3_7_version),
        ("scala_3_8", scala_3_8_version),
    ]
]

sh_test(
    name = "user_srcjar_no_warning_test",
    size = "large",
    srcs = ["success_test.sh"],
    # Not in compiler_sources_integrity.bzl nor a version compiler_srcjar knows
    # about, so this can only succeed via the compiler_srcjar tag MODULE.bazel
    # configures for it (with a real integrity value, to keep the build fast).
    args = [
        "--scala-version",
        "3.1.999",
    ],
    data = _NESTED_BAZEL_DATA,
    tags = _NESTED_BAZEL_TAGS,
)

[
    sh_test(
        name = name,
        size = "large",
        srcs = ["failure_test.sh"],
        args = args,
        data = _NESTED_BAZEL_DATA,
        tags = _NESTED_BAZEL_TAGS,
    )
    for name, args in [
        (
            # Not in compiler_sources_integrity.bzl nor configured as a
            # compiler_srcjar in MODULE.bazel.
            "fails_on_missing_scala2_integrity_test",
            [
                "--scala-version",
                "2.13.999",
                "--expect",
                _FAILED_MSG,
                "--expect",
                _REPO_URL_PREFIX + _SCALA_2_URL_SUFFIX.format(version = "2.13.999"),
            ],
        ),
        (
            # Not in compiler_sources_integrity.bzl nor configured as a
            # compiler_srcjar in MODULE.bazel.
            "fails_on_missing_scala3_integrity_test",
            [
                "--scala-version",
                "3.7.999",
                "--expect",
                _FAILED_MSG,
                "--expect",
                _REPO_URL_PREFIX + _SCALA_3_URL_SUFFIX.format(version = "3.7.999"),
            ],
        ),
        (
            # Beyond the current highest known major version, so the URL is
            # guessed using that highest major version's suffix (Scala 3's, for
            # now) until rules_scala adds real support for the new major.
            "fails_on_unknown_major_version_test",
            [
                "--scala-version",
                "4.0.999",
                "--expect",
                _FAILED_MSG,
                "--expect",
                _REPO_URL_PREFIX + _SCALA_3_URL_SUFFIX.format(version = "4.0.999"),
            ],
        ),
        (
            # Configured in MODULE.bazel as an empty compiler_srcjar dict.
            "fails_on_empty_compiler_srcjar_test",
            [
                "--scala-version",
                "3.1.1000",
                "--expect",
                "'scala_compiler_srcjar invalid, must be a dict with exactly " +
                "one of \"label\", \"url\" or \"urls\" keys, got: '",
            ],
        ),
    ]
]
