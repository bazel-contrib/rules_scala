#
# PHASE: coverage
#
# Adds `InstrumentedFilesInfo` to the rule's providers. It tells
# `bazel coverage` which source files belong to the target and which
# dependencies to follow. phase_compile does the instrumentation.
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
