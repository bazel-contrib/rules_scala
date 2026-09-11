"""Macro for asserting on the coverage.dat produced by a `bazel coverage` run.

Bazel has no native "run bazel coverage and inspect the result" rule, so this
wraps an `sh_test` around coverage_test.sh, which runs a nested `bazel
coverage` (see nested_bazel.sh) and then either diffs the resulting
coverage.dat against a checked-in expectation or greps it for a line.
"""

load("@rules_shell//shell:sh_test.bzl", "sh_test")

_COVERAGE_TEST_SH = "//test/coverage_test:coverage_test.sh"
_NESTED_BAZEL_LIB = "//test/expect_build_failure:nested_bazel.sh"

def _absolutize(target):
    # The nested `bazel coverage` runs from the workspace root, so a
    # package-relative label must be absolutized against this package first --
    # otherwise it would resolve against the root package.
    if target.startswith("//") or target.startswith("@"):
        return target
    elif target.startswith(":"):
        return "//%s%s" % (native.package_name(), target)
    else:
        return "//%s:%s" % (native.package_name(), target)

def coverage_test(
        name,
        target,
        expected_file = None,
        expected_line = None,
        bazel_args = [],
        size = "large",
        tags = [
            "no-sandbox",
            "external",
            "exclusive",
            "requires-network",
            "no-release",
            "skip-toolchain-sweep",
        ],
        **kwargs):
    """Declares an sh_test asserting a nested `bazel coverage` of `target` and its coverage.dat.

    Exactly one of `expected_file`/`expected_line` must be given; both check
    the real run's coverage.dat, not the command's own output. Tagged
    `external` rather than fingerprinted for caching: the nested build reads
    the real source tree, not this test's runfiles (see nested_bazel.sh module
    docstring), so there is no correct cache key to give it short of never
    caching at all -- `external` is Bazel's own way of saying that. Tagged
    `exclusive` because every coverage_test shares one nested output base (see
    nested_bazel.sh): two of these running at once could race on the same
    fixture's coverage.dat (e.g. one run's --instrument_test_targets=True
    result landing where another run without it expected to read its own).
    Tagged `no-release`, like every other disk-heavy nested-bazel test, so the
    release workflow's constrained disk budget skips it. Tagged
    `skip-toolchain-sweep`: the nested `bazel coverage` runs under its own
    output base with its own flags, so the outer build's `--extra_toolchains`
    never reaches it and every toolchain sweep would otherwise repeat the same
    result test_rules_scala.sh's default sweep already checked.

    Args:
        name: test target name.
        target: label whose nested `bazel coverage` must succeed. A
            package-relative label (`":foo"` or `"foo"`) is resolved against
            this package.
        expected_file: workspace-relative path to a checked-in coverage.dat
            that the real run's coverage.dat must match exactly.
        expected_line: pattern that must appear in the real run's coverage.dat.
        bazel_args: extra flags forwarded verbatim to the nested `bazel
            coverage` (e.g. `"--instrument_test_targets=True"`).
        size: test size; defaults to `"large"` (the nested Bazel invocation is
            slow and, on a cold cache, serializes on the shared output base).
        tags: test tags; see the defaults above and their rationale in this
            docstring's first paragraph.
        **kwargs: forwarded to the underlying `sh_test` (e.g. extra `data`).
    """
    if (expected_file == None) == (expected_line == None):
        fail("coverage_test %s needs exactly one of expected_file or expected_line" % name)

    args = ["--target", _absolutize(target)]
    for bazel_arg in bazel_args:
        args += ["--bazel-arg", bazel_arg]
    if expected_file:
        args += ["--expected", expected_file]
    else:
        args += ["--grep", expected_line]

    sh_test(
        name = name,
        size = size,
        srcs = [_COVERAGE_TEST_SH],
        args = args,
        data = [
            "//:MODULE.bazel",
            _NESTED_BAZEL_LIB,
        ],
        tags = tags,
        # `bazel coverage` doesn't produce a coverage.dat on Windows yet.
        target_compatible_with = select({
            "@platforms//os:windows": ["@platforms//:incompatible"],
            "//conditions:default": [],
        }),
        **kwargs
    )
