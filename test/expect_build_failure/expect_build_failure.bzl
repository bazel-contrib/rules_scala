"""Macro for asserting that `bazel build` of a target fails.

Bazel has no native "expect this target to fail to build" rule, so we wrap an
`sh_test` around `expect_build_failure.sh` (which runs a nested `bazel build`).
This macro lets callers declare intent -- the target and the messages the build
output must/mustn't contain -- instead of hand-assembling the script's raw args,
`$(rootpath ...)` expansions, runfiles, and boilerplate tags on every call.
"""

load("@rules_shell//shell:sh_test.bzl", "sh_test")

_HELPER = "//test/expect_build_failure:expect_build_failure.sh"

# Sourced at runtime by _HELPER, so it must be present in the test's runfiles.
_NESTED_BAZEL_LIB = "//test/expect_build_failure:nested_bazel.sh"

def expect_build_failure_test(
        name,
        target,
        build_args = [],
        expect = [],
        reject = [],
        size = "large",
        tags = ["local", "requires-network"],
        **kwargs):
    """Declares an `sh_test` asserting that building `target` fails.

    Args:
        name: test target name.
        target: label whose `bazel build` must fail.
        build_args: extra flags forwarded verbatim to the nested `bazel build`
            (e.g. `"--repo_env=SCALA_VERSION=2.13.18"`).
        expect: file labels whose (newline-stripped) contents must appear in the
            build output. Automatically added to the test's `data`.
        reject: file labels whose (newline-stripped) contents must NOT appear in
            the build output. Automatically added to the test's `data`.
        size: test size; defaults to `"large"` (the nested Bazel invocation is
            slow and, on a cold cache, serializes on the shared output base).
        tags: test tags; defaults to `["local", "requires-network"]` because the
            nested `bazel build` fetches external repos and must run outside the
            sandbox.
        **kwargs: forwarded to the underlying `sh_test` (e.g. extra `data`).
    """
    args = ["--target", target]
    for build_arg in build_args:
        args += ["--build-arg", build_arg]
    for expect_file in expect:
        args += ["--expect-file", "$(rootpath %s)" % expect_file]
    for reject_file in reject:
        args += ["--reject-file", "$(rootpath %s)" % reject_file]

    # Both entries must be in the test's runfiles (a file reaches runfiles only if
    # it is a declared dependency):
    #   - MODULE.bazel: the helper has no other way to find the *real* source
    #     workspace under `bazel test` (BUILD_WORKSPACE_DIRECTORY is `bazel run`
    #     only; TEST_SRCDIR points at the runfiles copy). It reads this root
    #     marker -- a symlink back into the source tree -- and resolves it to the
    #     directory the nested `bazel build` must run in. See
    #     _nested_bazel_find_workspace in nested_bazel.sh.
    #   - nested_bazel.sh: sourced at runtime by the helper script.
    data = [
        "//:MODULE.bazel",
        _NESTED_BAZEL_LIB,
    ] + expect + reject + kwargs.pop("data", [])
    deduped_data = []
    for entry in data:
        if entry not in deduped_data:
            deduped_data.append(entry)

    sh_test(
        name = name,
        size = size,
        srcs = [_HELPER],
        args = args,
        data = deduped_data,
        tags = tags,
        **kwargs
    )
