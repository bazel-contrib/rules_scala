load("//scala:providers.bzl", _ScalacProvider = "ScalacProvider")

#
# PHASE: scalac provider
#
# DOCUMENT THIS
#
load("//scala/private/toolchain_deps:toolchain_deps.bzl", "find_deps_info_on", "find_deps_info_on_if_present")

def phase_scalac_provider(ctx, p):
    toolchain_type_label = "//scala:toolchain_type"

    library_classpath = find_deps_info_on(ctx, toolchain_type_label, "scala_library_classpath").deps
    compile_classpath = find_deps_info_on(ctx, toolchain_type_label, "scala_compile_classpath").deps
    macro_classpath = find_deps_info_on(ctx, toolchain_type_label, "scala_macro_classpath").deps

    # A custom scala_toolchain() caller predating scala_repl_classpath won't
    # have mapped it; fall back to the compile classpath it used to get.
    repl_classpath_info = find_deps_info_on_if_present(ctx, toolchain_type_label, "scala_repl_classpath")
    repl_classpath = repl_classpath_info.deps if repl_classpath_info else compile_classpath

    return _ScalacProvider(
        default_classpath = library_classpath,
        default_repl_classpath = repl_classpath,
        default_macro_classpath = macro_classpath,
    )
