"""Builds a target under a fixed set of toolchains, in the outer Bazel's build graph.

A `--extra_toolchains` transition makes the outer build give those toolchains
priority for the target, over any others already registered. The outer build
then compiles the target itself, so checking "does this build" is answered by
that one build alone.

The transition is set on this wrapper. The fixture itself keeps its plain,
untransitioned form, so other rules can still depend on it directly --
including tests that check it fails under the default toolchain.
"""

load("@bazel_skylib//rules:build_test.bzl", "build_test")

def _toolchains_transition_impl(_settings, attr):
    # Sets extra_toolchains to exactly attr.extra_toolchains. This fully
    # replaces the outer build's own extra_toolchains value.
    return {"//command_line_option:extra_toolchains": attr.extra_toolchains}

toolchains_transition = transition(
    implementation = _toolchains_transition_impl,
    inputs = [],
    outputs = ["//command_line_option:extra_toolchains"],
)

def _impl(ctx):
    return [DefaultInfo(files = ctx.attr.target[0][DefaultInfo].files)]

_build_under_toolchains = rule(
    implementation = _impl,
    attrs = {
        "extra_toolchains": attr.string_list(
            doc = "The toolchains given priority while building `target`.",
        ),
        "target": attr.label(cfg = toolchains_transition, mandatory = True),
    },
    doc = "Forwards `target`'s default outputs, built under `extra_toolchains`.",
)

def toolchain_build_test(name, target, extra_toolchains, **kwargs):
    """Asserts `target` builds under `extra_toolchains`, via a transitioned wrapper.

    Tagged "skip-toolchain-sweep": the transition above always sets
    `--extra_toolchains` to the fixed list this macro is given, so every
    outer sweep produces the same result. test_rules_scala.sh passes
    `--build_tag_filters=-skip-toolchain-sweep` / `--test_tag_filters=-skip-toolchain-sweep`
    to skip targets with this tag during its extra toolchain sweeps, since
    the default sweep already checks them. Both the wrapper this macro
    creates and the `build_test` itself carry the tag, so a wildcard build
    pattern that matches the wrapper directly is filtered out the same way.

    Args:
        name: test target name.
        target: label whose build must succeed under `extra_toolchains`.
        extra_toolchains: the toolchains `target` is built under.
        **kwargs: forwarded to the underlying `build_test`; a `tags` entry
            keeps its own tags, with "skip-toolchain-sweep" added.
    """
    tags = kwargs.pop("tags", [])
    if "skip-toolchain-sweep" not in tags:
        tags = tags + ["skip-toolchain-sweep"]

    under_name = name + "_under_toolchains"
    _build_under_toolchains(
        name = under_name,
        testonly = True,
        tags = tags,
        extra_toolchains = extra_toolchains,
        target = target,
    )
    build_test(
        name = name,
        targets = [":" + under_name],
        tags = tags,
        **kwargs
    )
