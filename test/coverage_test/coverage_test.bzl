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
        expected = None,
        grep = None,
        bazel_args = [],
        size = "large",
        tags = ["no-sandbox", "external", "exclusive", "requires-network"],
        **kwargs):
    """Declares an sh_test asserting a nested `bazel coverage` of `target` and its coverage.dat.

    Exactly one of `expected`/`grep` must be given. Tagged `external` rather
    than fingerprinted for caching: the nested build reads the real source
    tree, not this test's runfiles (see nested_bazel.sh module docstring), so
    there is no correct cache key to give it short of never caching at all --
    `external` is Bazel's own way of saying that. Tagged `exclusive` because
    every coverage_test shares one nested output base (see nested_bazel.sh):
    two of these running at once could race on the same fixture's coverage.dat
    (e.g. one run's --instrument_test_targets=True result landing where
    another run without it expected to read its own).

    Args:
        name: test target name.
        target: label whose nested `bazel coverage` must succeed. A
            package-relative label (`":foo"` or `"foo"`) is resolved against
            this package.
        expected: workspace-relative path to a checked-in coverage.dat that the
            real run's coverage.dat must match exactly.
        grep: pattern that must appear in the real run's coverage.dat.
        bazel_args: extra flags forwarded verbatim to the nested `bazel
            coverage` (e.g. `"--instrument_test_targets=True"`).
        size: test size; defaults to `"large"` (the nested Bazel invocation is
            slow and, on a cold cache, serializes on the shared output base).
        tags: test tags; defaults to
            `["no-sandbox", "external", "exclusive", "requires-network"]` --
            `no-sandbox` because the nested `bazel coverage` needs real
            filesystem access outside the sandbox; `external` keeps the result
            out of the cache entirely, since it has no correct cache key (see
            above); `exclusive` serializes every coverage_test against every
            other, since they share one nested output base (see above).
        **kwargs: forwarded to the underlying `sh_test` (e.g. extra `data`).
    """
    if (expected == None) == (grep == None):
        fail("coverage_test %s needs exactly one of expected or grep" % name)

    args = ["--target", _absolutize(target)]
    for bazel_arg in bazel_args:
        args += ["--bazel-arg", bazel_arg]
    if expected:
        args += ["--expected", expected]
    else:
        args += ["--grep", grep]

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
        **kwargs
    )
