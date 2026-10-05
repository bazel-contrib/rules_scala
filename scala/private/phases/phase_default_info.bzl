#
# PHASE: default_info
#
# Builds the rule's `DefaultInfo` from the results of all earlier phases:
# an `executable` field becomes the executable (at most one phase may set it),
# `files` fields become default outputs, and `runfiles` fields, plus the Java
# runtime, become runfiles.
#

load("//scala/private:rule_impls.bzl", "specified_java_runtime")

def phase_default_info(ctx, p):
    executable = None
    files = []
    direct = None
    runfiles = []

    java_runtime = specified_java_runtime(ctx)
    if java_runtime:
        runfiles.append(java_runtime.files)

    phase_names = dir(p)
    if "to_json" in phase_names:
        phase_names.remove("to_json")
    if "to_proto" in phase_names:
        phase_names.remove("to_proto")
    for phase_name in phase_names:
        phase = getattr(p, phase_name)

        if hasattr(phase, "executable"):
            if executable == None:
                executable = phase.executable
                direct = [executable]
            else:
                fail("only one executable may be provided")

        if hasattr(phase, "files"):
            files.append(phase.files)

        if hasattr(phase, "runfiles"):
            runfiles.append(phase.runfiles)

    return struct(
        external_providers = {
            "DefaultInfo": DefaultInfo(
                executable = executable,
                files = depset(direct = direct, transitive = files),
                # TODO:
                # Per Bazel documentation, we should avoid using collect_data. The core phases need to be updated
                # before we can make the adjustment.
                runfiles = ctx.runfiles(transitive_files = depset(direct = direct, transitive = runfiles), collect_data = True),
            ),
        },
    )
