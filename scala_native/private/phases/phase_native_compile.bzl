"""Phase for Scala Native NIR generation via nscplugin."""

load("@rules_java//java/common:java_info.bzl",
  "JavaInfo",
)

_SCALA_NATIVE_TOOLCHAIN_TYPE = "//scala_native:toolchain_type"

def phase_native_compile(ctx, p):
    """Configure nscplugin for NIR generation.
    
    This phase injects the Scala Native nscplugin compiler plugin
    which generates NIR (Native Intermediate Representation) files
    during Scala compilation.
    
    Args:
        ctx: The rule context.
        p: The phase context from previous phases.
        
    Returns:
        A struct with scalacopts and plugin to be added to compilation,
        or None if Scala Native toolchain is not configured.
    """
    # Check if Scala Native toolchain is available
    if _SCALA_NATIVE_TOOLCHAIN_TYPE not in ctx.toolchains:
        return None
    toolchain = ctx.toolchains[_SCALA_NATIVE_TOOLCHAIN_TYPE]
    if toolchain == None:
        return None
    # Scalaworker automatically adds the -Xplugin to scalaops
    # as long as the plugin field in the the struct below is set correctly.
    return struct(
        scalacopts = [],
        plugin = [toolchain.nscplugin],
    )
