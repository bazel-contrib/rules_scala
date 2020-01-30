# Gathers information about dependency mode and analysis

load(
    "@io_bazel_rules_scala//scala/private:dependency.bzl",
    "get_dependency_mode",
    "get_strict_deps_mode",
    "get_unused_deps_mode",
    "new_dependency_info",
)

def _phase_dependency_default(ctx, p, args = struct()):
    return _phase_dependency(
        ctx = ctx,
        p = p,
        unused_deps_always_off = args.unused_deps_always_off if hasattr(args, "unused_deps_always_off") else False,
        strict_deps_always_off = args.strict_deps_always_off if hasattr(args, "strict_deps_always_off") else False,
    )

def _phase_dependency(
        ctx,
        p,
        unused_deps_always_off,
        strict_deps_always_off):
    if strict_deps_always_off:
        strict_deps_mode = "off"
    else:
        strict_deps_mode = get_strict_deps_mode(ctx)

    if unused_deps_always_off:
        unused_deps_mode = "off"
    else:
        unused_deps_mode = get_unused_deps_mode(ctx)

    return new_dependency_info(
        dependency_mode = get_dependency_mode(ctx),
        unused_deps_mode = unused_deps_mode,
        strict_deps_mode = strict_deps_mode,
        dependency_tracking_method = "high-level",
    )

def phase_dependency_common(ctx, p):
    return _phase_dependency_default(ctx, p)

def phase_dependency_library_for_plugin_bootstrapping(ctx, p):
    args = struct(
        unused_deps_always_off = True,
        strict_deps_always_off = True,
    )
    return _phase_dependency_default(ctx, p, args)
