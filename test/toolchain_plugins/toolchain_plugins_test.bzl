"""Analysis tests for toolchain-level compiler plugins.

The plugin jar is never executed (analysis only), so the tests work on every
Scala version. Execution of `--Plugins` args is already covered by the
target-level plugins tests; toolchain plugins join the same list in
`phase_compile`.
"""

load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")

# The jar `//test/toolchain_plugins:with_plugin` injects; any jar would do.
_PLUGIN_JAR = "dummy_plugin.jar"

def _scalac_argv(env):
    for action in analysistest.target_actions(env):
        if action.mnemonic == "Scalac":
            return action.argv
    return None

def _has_plugin_arg(argv):
    return any([_PLUGIN_JAR in arg for arg in argv])

def _toolchain_plugin_present_test(ctx):
    env = analysistest.begin(ctx)
    argv = _scalac_argv(env)
    asserts.false(env, argv == None, "expected a Scalac action")
    asserts.true(
        env,
        _has_plugin_arg(argv),
        "expected the toolchain's plugin jar in the scalac command line",
    )
    return analysistest.end(env)

def _toolchain_plugin_absent_test(ctx):
    env = analysistest.begin(ctx)
    argv = _scalac_argv(env)
    asserts.false(env, argv == None, "expected a Scalac action")
    asserts.false(
        env,
        _has_plugin_arg(argv),
        "did not expect the plugin jar in the scalac command line",
    )
    return analysistest.end(env)

toolchain_plugin_present_test = analysistest.make(
    _toolchain_plugin_present_test,
    config_settings = {
        "//command_line_option:extra_toolchains": [
            "//test/toolchain_plugins:with_plugin",
        ],
    },
)

toolchain_plugin_absent_test = analysistest.make(
    _toolchain_plugin_absent_test,
    config_settings = {
        "//command_line_option:extra_toolchains": [],
    },
)
