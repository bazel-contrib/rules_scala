"""Builds a target under one fixed toolchain, in the outer Bazel's build graph.

A `--extra_toolchains` transition makes the outer build pick that toolchain
for the target, over any others already registered. So the outer build
compiles the target itself, and checking "does this build" just means
checking the outer build's own result -- no second, nested `bazel` process.

The transition is set here, on this wrapper, not on the fixture itself. That
way other rules can still depend on the fixture in its normal form, for tests
that check it fails under the default toolchain.
"""

load("@bazel_skylib//rules:build_test.bzl", "build_test")

def _toolchains_transition_impl(_settings, attr):
    # Whatever the outer build set for extra_toolchains is replaced, not
    # added to: the transitioned target always uses this fixed list instead.
    return {"//command_line_option:extra_toolchains": attr.extra_toolchains}

toolchains_transition = transition(
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
        "target": attr.label(cfg = toolchains_transition),
    },
    doc = "Forwards `target`'s default outputs, built under `extra_toolchains`.",
)

def toolchain_build_test(name, target, extra_toolchains, **kwargs):
    """Asserts `target` builds under `extra_toolchains`, via `build_under_toolchains`.

    Tagged "fixed-toolchain": the transition above always sets
    `--extra_toolchains` to the fixed list this macro is given, so the
    result is the same no matter which toolchain an outer sweep sets. In
    test_rules_scala.sh, the `toolchain-sweep` `.bazelrc` config skips
    targets with this tag during the extra toolchain sweeps, since the
    default sweep already checks them.

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
        # "manual": only the build_test below should reach this target. If a
        # wildcard build pattern matched it directly too, it would build
        # this target again under `extra_toolchains`, once per toolchain
        # sweep -- exactly the extra work the "fixed-toolchain" tag on the
        # build_test is meant to avoid.
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
