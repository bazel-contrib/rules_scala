load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def _no_exec_config_deps_test(ctx):
    """Fails if the target's runfiles hold a file built for another configuration.

    Build-time tools (protoc, the scrooge compiler, scalac) are built in the exec
    configuration. A jar of theirs among the runfiles means the rule put a build-time
    dependency on the runtime classpath of what it ships.
    """
    env = analysistest.begin(ctx)

    # Every File has a root: an empty path for a source, otherwise the output directory
    # of the configuration that built it. ctx.bin_dir is that directory for the
    # configuration the test and its target under test are analyzed in. A build has more
    # than one exec output directory, so the check accepts that single root instead of
    # matching exec ones.
    runfiles = analysistest.target_under_test(env)[DefaultInfo].default_runfiles.files.to_list()
    foreign = [f.path for f in runfiles if f.root.path not in ["", ctx.bin_dir.path]]

    asserts.equals(
        env,
        [],
        foreign,
        "runfiles may only hold sources and files built for %s" % ctx.bin_dir.path,
    )

    return analysistest.end(env)

no_exec_config_deps_test = analysistest.make(_no_exec_config_deps_test)
