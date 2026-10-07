#
# PHASE: collect exports jars
#
# Collects the jars of `exports`. The builtin rules leave this phase out
# (phase_compile reads `ctx.attr.exports` itself); a custom rule or phase
# adjustment can add it, and later phases read the result as
# `p.collect_exports_jars`.
#
load("//scala/private:common.bzl", "collect_jars")

def phase_collect_exports_jars(ctx, p):
    # Add information from exports (is key that AFTER all build actions/runfiles analysis)
    # Since after, will not show up in deploy_jar or old jars runfiles
    # Notice that compile_jars is intentionally transitive for exports
    return collect_jars(
        ctx.attr.exports,
        "direct",
        False,
        False,
    )
