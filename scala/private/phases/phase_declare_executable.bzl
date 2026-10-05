#
# PHASE: declare executable
#
# Declares the launcher file: `<name>.exe` on Windows, `<name>` elsewhere.
# phase_write_executable writes it, and phase_default_info returns it as the
# rule's executable.
#
load("//scala/private:rule_impls.bzl", "is_windows")

def phase_declare_executable(ctx, p):
    if (is_windows(ctx)):
        return struct(
            executable = ctx.actions.declare_file("%s.exe" % ctx.label.name),
        )
    else:
        return struct(
            executable = ctx.actions.declare_file(ctx.label.name),
        )
