#
# PHASE: coverage runfiles
#
# DOCUMENT THIS
#

def phase_coverage_runfiles(ctx, p):
    coverage_runfiles = []
    if ctx.configuration.coverage_enabled:
        jacocorunner = ctx.toolchains["//scala:toolchain_type"].jacocorunner
        coverage_runfiles = jacocorunner.files.to_list() + ctx.files._lcov_merger
    return struct(
        coverage_runfiles = coverage_runfiles,
        runfiles = depset(coverage_runfiles),
    )
