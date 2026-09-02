"""Builds a target under a fixed toolchain, in the outer Bazel's graph.

A `--extra_toolchains` transition puts the fixture in a configuration where
that toolchain has the highest resolution priority, so the outer build
resolves it and compiles the fixture itself. Asserting "this builds" is then a
question the outer build already answers, with no nested `bazel` involved.

The transition is applied here rather than on the fixture, so the fixture
stays reachable untransitioned for tests that assert it fails under the
default toolchain.
"""

load("@bazel_skylib//rules:build_test.bzl", "build_test")

def _toolchains_transition_impl(_settings, attr):
    return {"//command_line_option:extra_toolchains": attr.extra_toolchains}

_toolchains_transition = transition(
    implementation = _toolchains_transition_impl,
    inputs = [],
    outputs = ["//command_line_option:extra_toolchains"],
)

def _impl(ctx):
    return [DefaultInfo(files = ctx.attr.target[0][DefaultInfo].files)]

build_under_toolchains = rule(
    implementation = _impl,
    attrs = {
        "extra_toolchains": attr.string_list(
            doc = "The only toolchains `target` is built under.",
        ),
        "target": attr.label(cfg = _toolchains_transition),
    },
    doc = "Forwards `target`'s default outputs, built under `extra_toolchains`.",
)

def toolchain_build_test(name, target, extra_toolchains, **kwargs):
    """Asserts `target` builds under `extra_toolchains`, via `build_under_toolchains`.

    Tagged "fixed-toolchain": the transition above always overrides
    `--extra_toolchains` to the fixed list this macro is given, so the result
    stays the same under whichever toolchain an outer sweep registers. The
    `toolchain-sweep` `.bazelrc` config strips this tag from the
    toolchain-matrix sweeps in test_rules_scala.sh, since the default sweep
    already covers it.

    Args:
        name: test target name.
        target: label whose build must succeed under `extra_toolchains`.
        extra_toolchains: the toolchains `target` is built under.
        **kwargs: forwarded to the underlying `build_test`; a `tags` entry is
            merged with "fixed-toolchain" rather than overwritten.
    """
    under_name = name + "_under_toolchains"
    build_under_toolchains(
        name = under_name,
        testonly = True,
        # "manual": this helper exists only as the build_test's dependency
        # below, so a wildcard build pattern must not select it on its own
        # (that would build it under `extra_toolchains` a second time, once
        # per toolchain-matrix sweep, defeating the "fixed-toolchain" tag on
        # the build_test that lets those sweeps skip it).
        tags = ["manual"],
        extra_toolchains = extra_toolchains,
        target = target,
    )
    tags = kwargs.pop("tags", [])
    if "fixed-toolchain" not in tags:
        tags = tags + ["fixed-toolchain"]
    build_test(
        name = name,
        targets = [":" + under_name],
        tags = tags,
        **kwargs
    )
