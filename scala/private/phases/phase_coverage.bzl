#
# PHASE: coverage
#
# Instrumentation itself happens in the compile phase; this phase only tells
# `bazel coverage` which sources belong to the target.
#

def phase_coverage_common(ctx, p):
    return struct(
        external_providers = {
            "InstrumentedFilesInfo": coverage_common.instrumented_files_info(
                ctx,
                source_attributes = ["srcs"],
                dependency_attributes = ["deps", "exports"],
                extensions = ["scala", "java"],
            ),
        },
    )
