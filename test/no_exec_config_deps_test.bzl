load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

def _no_exec_config_deps_test(ctx):
    env = analysistest.begin(ctx)

    runfiles = analysistest.target_under_test(env)[DefaultInfo].default_runfiles.files.to_list()

    # A file's root is empty for sources and otherwise names the configuration that
    # built it. Accept only the target configuration: a build has more than one exec
    # configuration, so matching exec output dirs would miss leaks from the others.
    foreign = [f.path for f in runfiles if f.root.path not in ["", ctx.bin_dir.path]]

    asserts.equals(env, [], foreign)

    return analysistest.end(env)

no_exec_config_deps_test = analysistest.make(_no_exec_config_deps_test)
