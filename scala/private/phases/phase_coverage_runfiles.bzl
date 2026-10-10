#
# PHASE: coverage runfiles
#
# In a coverage build, adds the JaCoCo runner from the Scala toolchain and the
# LCOV merger to the runfiles of scala_test and scala_junit_test.
# phase_default_info adds them to `DefaultInfo`.
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
