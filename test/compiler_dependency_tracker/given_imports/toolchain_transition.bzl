"""Builds a target under a fixed toolchain, in the outer Bazel's graph.

A `--extra_toolchains` transition puts the fixture in a configuration where the
pinned toolchain is the only registered one, so the outer build resolves it and
compiles the fixture itself. Asserting "this builds" is then whether the target
builds, and needs no nested `bazel`.

The transition is applied here rather than on the fixture, so the fixture stays
reachable untransitioned for tests that assert it fails under the default
toolchain.
"""

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
