load(
    "//scala/private/toolchain_deps:toolchain_deps.bzl",
    "expose_toolchain_deps",
    "find_deps_info_on_if_present",
    "java_info_for_deps",
)

_TOOLCHAIN_TYPE = "//scala:toolchain_type"

def _common_toolchain_deps(ctx):
    if ctx.attr.optional:
        deps_info = find_deps_info_on_if_present(ctx, _TOOLCHAIN_TYPE, ctx.attr.deps_id)
        return java_info_for_deps(deps_info.deps if deps_info else [])
    return expose_toolchain_deps(ctx, _TOOLCHAIN_TYPE)

common_toolchain_deps = rule(
    implementation = _common_toolchain_deps,
    attrs = {
        "deps_id": attr.string(mandatory = True),
        "optional": attr.bool(),
    },
    toolchains = [_TOOLCHAIN_TYPE],
)
