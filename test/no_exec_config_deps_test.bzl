load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def _foreign_runfiles(env, ctx):
    # Every File has a root: an empty path for a source, otherwise the output directory
    # of the configuration that built it. ctx.bin_dir is that directory for the
    # configuration the test and its target under test are analyzed in. A build has more
    # than one exec output directory, so the check accepts that single root instead of
    # matching exec ones.
    runfiles = analysistest.target_under_test(env)[DefaultInfo].default_runfiles.files.to_list()
    return [f.path for f in runfiles if f.root.path not in ["", ctx.bin_dir.path]]

def _no_exec_config_deps_test(ctx):
    """Fails if the target's runfiles hold a file built for another configuration.

    Build-time tools (protoc, the scrooge compiler, scalac) are built in the exec
    configuration. A jar of theirs among the runfiles means the rule put a build-time
    dependency on the runtime classpath of what it ships.
    """
    env = analysistest.begin(ctx)

    asserts.equals(
        env,
        [],
        _foreign_runfiles(env, ctx),
        "runfiles may only hold sources and files built for %s" % ctx.bin_dir.path,
    )

    return analysistest.end(env)

def _detects_exec_config_deps_test(ctx):
    """Fails if the check above stays quiet about a target that does leak a build-time tool.

    Keeps the check honest across Bazel upgrades: if output roots ever stop telling
    configurations apart, this test fails instead of the check passing everything.
    """
    env = analysistest.begin(ctx)

    asserts.true(
        env,
        _foreign_runfiles(env, ctx) != [],
        "runfiles of %s hold scalac, built in the exec configuration" % ctx.attr.target_under_test.label,
    )

    return analysistest.end(env)

no_exec_config_deps_test = analysistest.make(_no_exec_config_deps_test)

detects_exec_config_deps_test = analysistest.make(_detects_exec_config_deps_test)

def _exec_config_dep_leak(ctx):
    return [DefaultInfo(runfiles = ctx.runfiles(files = ctx.files._build_time_tool))]

exec_config_dep_leak = rule(
    doc = "Puts a build-time tool on the runtime classpath, the mistake the tests above look for.",
    implementation = _exec_config_dep_leak,
    attrs = {
        "_build_time_tool": attr.label(
            cfg = "exec",
            default = "//src/java/io/bazel/rulesscala/scalac",
        ),
    },
)
