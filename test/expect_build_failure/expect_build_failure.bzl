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
        worker_sandboxing = False,
        expect = [],
        reject = [],
        size = "large",
        tags = ["local", "requires-network"],
        **kwargs):
    """Declares an `sh_test` asserting that building `target` fails.

    Args:
        name: test target name.
        target: label whose `bazel build` must fail. A package-relative label
            (`":foo"` or `"foo"`) is resolved against this package.
        build_args: extra flags forwarded verbatim to the nested `bazel build`
            (e.g. `"--repo_env=SCALA_VERSION=2.13.18"`).
        worker_sandboxing: if True, pass `--worker_sandboxing` to the nested
            `bazel build` -- but only on non-Windows, since Bazel worker
            sandboxing is not implemented on Windows (mirrors the historical
            guard in test/shell/test_persistent_worker.sh; without it the nested
            scalac worker fails to start with a missing-JVM error instead of
            producing the compile failure under test).
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
    # The nested `bazel build` runs from the workspace root, so a package-relative
    # label must be absolutized against this package first -- otherwise it would
    # resolve against the root package.
    if target.startswith("//") or target.startswith("@"):
        absolute_target = target
    elif target.startswith(":"):
        absolute_target = "//%s%s" % (native.package_name(), target)
    else:
        absolute_target = "//%s:%s" % (native.package_name(), target)

    args = ["--target", absolute_target]
    for build_arg in build_args:
        args += ["--build-arg", build_arg]
    for expect_file in expect:
        args += ["--expect-file", "$(rootpath %s)" % expect_file]
    for reject_file in reject:
        args += ["--reject-file", "$(rootpath %s)" % reject_file]
    if worker_sandboxing:
        args = args + select({
            "@platforms//os:windows": [],
            "//conditions:default": ["--build-arg", "--worker_sandboxing"],
        })

    # The nested `bazel build` reads the *real* source tree, not the runfiles, so
    # `target` and its sources are not otherwise inputs of this `sh_test`: without
    # help Bazel would serve a cached PASS even after the code under test changed
    # (a false green). We can't just add `target` to `data` -- it is expected to
    # fail to build, which would break this test's own build -- and a macro can't
    # introspect a target's `srcs`. So glob every source file in this package and
    # declare it as runfiles: editing any of them changes the test's cache key and
    # forces a re-run. This covers the common case of a fixture whose sources live
    # alongside its BUILD file; a `target` in another package is not tracked (pass
    # its sources via `data` if you need that).
    code_under_test = native.glob(["**/*"], allow_empty = True)

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
    ] + expect + reject + code_under_test + kwargs.pop("data", [])

    # De-duplicate by canonical label: `code_under_test` re-lists files that are
    # also named explicitly (e.g. the expect/reject `.txt`s, passed as `:foo.txt`),
    # and Bazel rejects a label that resolves to the same target twice in `data`.
    # Compare canonical labels so `foo`, `:foo` and `//pkg:foo` collapse to one.
    deduped_data = []
    seen = {}
    for entry in data:
        if entry.startswith("//") or entry.startswith("@"):
            key = entry
        elif entry.startswith(":"):
            key = "//%s%s" % (native.package_name(), entry)
        else:
            key = "//%s:%s" % (native.package_name(), entry)
        if key not in seen:
            seen[key] = True
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
