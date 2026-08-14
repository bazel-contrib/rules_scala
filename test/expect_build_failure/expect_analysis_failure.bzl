"""Asserts that a target fails during analysis.

The nested-Bazel `expect_*_test` macros next door handle failures that surface
once an action runs (a compile error, a failing test binary). This one asks
Bazel directly, in-process: hermetic and cacheable. Prefer it whenever the
failure is at analysis time.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def _impl(ctx):
    env = analysistest.begin(ctx)
    asserts.expect_failure(env, ctx.attr.message)
    return analysistest.end(env)

expect_analysis_failure_test = analysistest.make(
    _impl,
    expect_failure = True,
    attrs = {"message": attr.string(mandatory = True, doc = "Substring the analysis error must contain.")},
)
