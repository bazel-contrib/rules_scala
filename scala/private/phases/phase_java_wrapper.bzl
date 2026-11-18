#
# PHASE: java wrapper
#
# Writes `<name>_wrapper.sh`, which runs `java` from the target's Java runtime,
# or `$REAL_EXTERNAL_JAVA_BIN` when set. The REPL variant also passes
# `scalacopts` and restores terminal settings on exit. phase_write_executable
# uses the wrapper for the Unix launcher.
#
load("@bazel_skylib//lib:paths.bzl", "paths")
load("//scala/private:rule_impls.bzl", "java_bin_rlocationpath")

def phase_java_wrapper_repl(ctx, p):
    args = struct(
        args = " ".join(ctx.attr.scalacopts),
        wrapper_preamble = """
# save stty like in bin/scala
saved_stty=$(stty -g 2>/dev/null)
if [[ ! $? ]]; then
  saved_stty=""
fi
function finish() {
  if [[ "$saved_stty" != "" ]]; then
    stty $saved_stty
    saved_stty=""
  fi
}
trap finish EXIT
""",
    )
    return _phase_java_wrapper_default(ctx, p, args)

def phase_java_wrapper_common(ctx, p):
    return _phase_java_wrapper_default(ctx, p)

def _phase_java_wrapper_default(ctx, p, _args = struct()):
    return _phase_java_wrapper(
        ctx,
        _args.args if hasattr(_args, "args") else "",
        _args.wrapper_preamble if hasattr(_args, "wrapper_preamble") else "",
    )

def _phase_java_wrapper(
        ctx,
        args,
        wrapper_preamble):
    """This creates a wrapper that sets up the correct path
         to stand in for the java command."""

    exec_str = ""
    if wrapper_preamble == "":
        exec_str = "exec "

    java = java_bin_rlocationpath(ctx)
    if paths.is_absolute(java):
        find_java = "JAVA_EXEC_TO_USE=${{REAL_EXTERNAL_JAVA_BIN:-{java}}}".format(java = java)
    else:
        # The launcher exports JAVA_RUNFILES and RUNFILES_MANIFEST_FILE. Without a
        # runfiles tree (--noenable_runfiles) java is only in the manifest.
        find_java = """JAVA_EXEC_TO_USE=$REAL_EXTERNAL_JAVA_BIN
if [[ -z "$JAVA_EXEC_TO_USE" ]]; then
  JAVA_EXEC_TO_USE="$JAVA_RUNFILES/{key}"
  if [[ ! -e "$JAVA_EXEC_TO_USE" ]]; then
    JAVA_EXEC_TO_USE=$(awk -v key='{key}' '{{ sub(/\\r$/, "") }} $1 == key {{ sub(/^[^ ]* /, ""); print; exit }}' "$RUNFILES_MANIFEST_FILE")
    if [[ -z "$JAVA_EXEC_TO_USE" ]]; then
      echo "$0: cannot find runfile {key} in runfiles tree '$JAVA_RUNFILES' or manifest '$RUNFILES_MANIFEST_FILE'" >&2
      exit 1
    fi
  fi
fi""".format(key = java)

    wrapper = ctx.actions.declare_file(ctx.label.name + "_wrapper.sh")
    ctx.actions.write(
        output = wrapper,
        content = """#!/usr/bin/env bash
{preamble}
{find_java}
{exec_str}$JAVA_EXEC_TO_USE "$@" {args}
""".format(
            preamble = wrapper_preamble,
            find_java = find_java,
            exec_str = exec_str,
            args = args,
        ),
        is_executable = True,
    )
    return wrapper
