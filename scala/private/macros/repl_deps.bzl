"""Extra classpath entries scala_repl needs beyond scala_compile_classpath.

Finer-grained than setup_scala_toolchain.bzl's _DEFAULT_DEPS ("any", "2", "3").
From 3.8, dotty.tools.repl.Main lives in its own artifact.
From 3.9, that artifact's dependencies changed, and newer minors keep those repository names.
Pinned coordinates live in third_party/repositories/scala_<major>_<minor>.bzl.
"""
_REPL_DEPS_3_8 = [
    "@com_lihaoyi_fansi_3",
    "@com_lihaoyi_pprint_repl",
    "@com_lihaoyi_sourcecode_3",
    "@io_get_coursier_interface",
    "@org_scala_lang_scala3_repl",
    "@org_slf4j_slf4j_api",
    "@org_virtuslab_using_directives",
]

_REPL_DEPS_SINCE_3_9 = [
    "@io_get_coursier_interface",
    "@org_jline_jline_native_4",
    "@org_jline_jline_reader_4",
    "@org_jline_jline_terminal_4",
    "@org_jline_jline_terminal_jni_4",
    "@org_scala_lang_scala3_directives_parser",
    "@org_scala_lang_scala3_repl",
    "@org_slf4j_slf4j_api",
]

def _scala3_minor(scala_version):
    if not scala_version.startswith("3."):
        return None
    parts = scala_version.split("-")[0].split(".")
    if len(parts) < 2:
        return None
    return int(parts[1])

def repl_extra_deps(scala_version):
    """Deps scala_repl needs on top of scala_compile_classpath.

    Args:
        scala_version: Scala version string.

    Returns:
        List of "@repo" labels; empty when the compiler classpath suffices.
    """
    minor = _scala3_minor(scala_version)
    if minor == 8:
        return _REPL_DEPS_3_8
    if minor != None and minor >= 9:
        return _REPL_DEPS_SINCE_3_9
    return []

def repl_is_known_supported(scala_version):
    """Whether scala_repl can build a working classpath for this version.

    Lets scala_repl fail at analysis time instead of at REPL startup.

    Args:
        scala_version: Scala version string.

    Returns:
        True if repl_extra_deps covers this version.
    """
    minor = _scala3_minor(scala_version)
    if minor == None or minor < 8:
        return True
    return repl_extra_deps(scala_version) != []
