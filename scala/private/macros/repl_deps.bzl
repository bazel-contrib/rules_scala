# scala_repl's extra deps key off the exact minor version, finer-grained
# than setup_scala_toolchain.bzl's _DEFAULT_DEPS "any"/"2"/"3" major-version
# buckets: from 3.8 dotty.tools.repl.Main moved into its own artifact, and
# 3.9 changed that artifact's own deps again (see phase_write_executable_repl
# and the two third_party/repositories/scala_3_{8,9}.bzl files for the full
# story).
_REPL_EXTRA_DEPS = {
    "3.8.": [
        "@com_lihaoyi_fansi_3",
        "@com_lihaoyi_pprint_repl",
        "@com_lihaoyi_sourcecode_3",
        "@io_get_coursier_interface",
        "@org_scala_lang_scala3_repl",
        "@org_slf4j_slf4j_api",
        "@org_virtuslab_using_directives",
    ],
    "3.9.": [
        "@io_get_coursier_interface",
        "@org_jline_jline_native_4",
        "@org_jline_jline_reader_4",
        "@org_jline_jline_terminal_4",
        "@org_jline_jline_terminal_jni_4",
        "@org_scala_lang_scala3_directives_parser",
        "@org_scala_lang_scala3_repl",
        "@org_slf4j_slf4j_api",
    ],
}

def repl_extra_deps(scala_version):
    """The extra deps a scala_repl needs on top of scala_compile_classpath.

    Returns [] both for a Scala 3 minor version that genuinely needs nothing
    extra (3.1 through 3.7: dotty.tools.repl.Main still lives inside
    scala3-compiler there) and for one this mapping has yet to cover.
    repl_is_known_supported, called at scala_repl analysis time, is what
    tells those two apart.
    """
    for prefix, deps in _REPL_EXTRA_DEPS.items():
        if scala_version.startswith(prefix):
            return deps
    return []

def repl_is_known_supported(scala_version):
    """False for a Scala 3 minor version >= 3.8 with no repl_extra_deps entry.

    3.8 and 3.9 each changed scala_repl's own deps once already, so treat a
    future 3.x minor this mapping has yet to cover as unknown territory,
    requiring an update here, rather than assuming it needs nothing:
    silently assuming that would build a scala_repl that fails at runtime
    with ClassNotFoundException. Called only when a scala_repl target is
    actually analyzed, scoping the check to the targets it actually concerns
    rather than every general toolchain/repository setup.
    """
    if not scala_version.startswith("3.") or int(scala_version.split(".")[1]) < 8:
        return True
    return repl_extra_deps(scala_version) != []
