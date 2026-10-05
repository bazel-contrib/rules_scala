#
# PHASE: collect exports jars
#
# Collects the jars of `exports`. Builtin phases leave this result unused
# (phase_compile reads `ctx.attr.exports` itself); custom phases can read it
# as `p.collect_exports_jars`.
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
