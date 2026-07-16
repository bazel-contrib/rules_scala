"""Macros for asserting the outcome of a nested `bazel <command>` of a target.

Bazel has no native "run bazel and assert on the outcome" rule, so we wrap an
`sh_test` around `expect_build_failure.sh` (which runs a nested `bazel build`,
`bazel test` or `bazel coverage`). These macros let callers declare intent --
the target, the subcommand, and the messages the output must/mustn't contain --
instead of hand-assembling the script's raw args, `$(rootpath ...)` expansions,
runfiles, and boilerplate tags on every call.

- `expect_build_failure_test` asserts a `bazel build` fails.
- `expect_test_failure_test` asserts a `bazel test` (or `bazel coverage`) fails.
- `expect_test_success_test` asserts a `bazel test` succeeds (e.g. a fixture that
  only passes under a specific `--test_filter` or inherited env var).

All three share the same script and nested-Bazel plumbing.
"""

load("@rules_shell//shell:sh_test.bzl", "sh_test")

_HELPER = "//test/expect_build_failure:expect_build_failure.sh"

# Sourced at runtime by _HELPER, so it must be present in the test's runfiles.
_NESTED_BAZEL_LIB = "//test/expect_build_failure:nested_bazel.sh"

def _absolutize(target):
    # The nested `bazel <command>` runs from the workspace root, so a
    # package-relative label must be absolutized against this package first --
    # otherwise it would resolve against the root package.
    if target.startswith("//") or target.startswith("@"):
        return target
    elif target.startswith(":"):
        return "//%s%s" % (native.package_name(), target)
    else:
        return "//%s:%s" % (native.package_name(), target)

def _nested_bazel_test(
        name,
        command,
        target,
        bazel_args,
        expect_success,
        env,
        worker_sandboxing,
        expect,
        reject,
        size,
        tags,
        **kwargs):
    args = ["--command", command, "--target", _absolutize(target)]
    if expect_success:
        args += ["--expect-success"]
    for key in env:
        value = env[key]
        # Same Bourne-tokenization guard as bazel_args below: an env value with a
        # space would otherwise be split into two `sh_test` args, and the helper
        # would reject the stray token.
        if " " in value:
            value = "'%s'" % value
        args += ["--env", "%s=%s" % (key, value)]
    for bazel_arg in bazel_args:
        # Bazel applies Bourne tokenization to `sh_test` `args`, which would split
        # a flag containing spaces (e.g. `--test_arg=test 1`) into two tokens.
        # Single-quote such values so tokenization keeps them whole.
        if " " in bazel_arg:
            bazel_arg = "'%s'" % bazel_arg
        args += ["--bazel-arg", bazel_arg]
    for expect_file in expect:
        args += ["--expect-file", "$(rootpath %s)" % expect_file]
    for reject_file in reject:
        args += ["--reject-file", "$(rootpath %s)" % reject_file]
    if worker_sandboxing:
        args = args + select({
            "@platforms//os:windows": [],
            "//conditions:default": ["--bazel-arg", "--worker_sandboxing"],
        })

    # The nested `bazel <command>` reads the *real* source tree, not the runfiles,
    # so `target` and its sources are not otherwise inputs of this `sh_test`:
    # without help Bazel would serve a cached result even after the code under
    # test changed (a false green -- a negative test that silently stops
    # re-running). We can't just add `target` to `data`: the failure-asserting
    # macros expect it to *fail* to build, which would break this test's own
    # build, and a macro can't introspect a target's `srcs` anyway. So glob every
    # source file in this package and declare it as runfiles: editing any of them
    # changes the test's cache key and forces a re-run. This covers the common
    # case of a fixture whose sources live alongside its BUILD file; a `target` in
    # another package is not tracked (pass its sources via `data` if you need
    # that).
    code_under_test = native.glob(["**/*"], allow_empty = True)

    # Both entries must be in the test's runfiles (a file reaches runfiles only if
    # it is a declared dependency):
    #   - MODULE.bazel: the helper has no other way to find the *real* source
    #     workspace under `bazel test` (BUILD_WORKSPACE_DIRECTORY is `bazel run`
    #     only; TEST_SRCDIR points at the runfiles copy). It reads this root
    #     marker -- a symlink back into the source tree -- and resolves it to the
    #     directory the nested `bazel <command>` must run in. See
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
    """Declares an `sh_test` asserting that `bazel build` of `target` fails.

    Args:
        name: test target name.
        target: label whose `bazel build` must fail. A package-relative label
            (`":foo"` or `"foo"`) is resolved against this package. The caller
            must tag this fixture `"manual"`: it is expected to fail to build and
            would otherwise break a plain wildcard `bazel build //...`.
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
    _nested_bazel_test(
        name = name,
        command = "build",
        target = target,
        bazel_args = build_args,
        expect_success = False,
        env = {},
        worker_sandboxing = worker_sandboxing,
        expect = expect,
        reject = reject,
        size = size,
        tags = tags,
        **kwargs
    )

def expect_test_failure_test(
        name,
        target,
        command = "test",
        bazel_args = [],
        worker_sandboxing = False,
        expect = [],
        reject = [],
        size = "large",
        tags = ["local", "requires-network"],
        **kwargs):
    """Declares an `sh_test` asserting that `bazel test`/`coverage` of `target` fails.

    Same plumbing as `expect_build_failure_test`, but the nested invocation is
    `bazel test` (or `bazel coverage`), so the failure being asserted is a test
    run / coverage failure rather than a build failure.

    Args:
        name: test target name.
        target: label whose nested run must fail. A package-relative label
            (`":foo"` or `"foo"`) is resolved against this package. The caller
            must tag this fixture `"manual"`: it is expected to fail and would
            otherwise break a plain wildcard `bazel test //...`.
        command: the bazel subcommand to run; `"test"` (default) or `"coverage"`.
        bazel_args: extra flags forwarded verbatim to the nested `bazel <command>`
            (e.g. `"--extra_toolchains=//some:failing_toolchain"`).
        worker_sandboxing: see `expect_build_failure_test`.
        expect: file labels whose (newline-stripped) contents must appear in the
            output. Automatically added to the test's `data`.
        reject: file labels whose (newline-stripped) contents must NOT appear in
            the output. Automatically added to the test's `data`.
        size: test size; defaults to `"large"`.
        tags: test tags; defaults to `["local", "requires-network"]`.
        **kwargs: forwarded to the underlying `sh_test` (e.g. extra `data`).
    """
    _nested_bazel_test(
        name = name,
        command = command,
        target = target,
        bazel_args = bazel_args,
        expect_success = False,
        env = {},
        worker_sandboxing = worker_sandboxing,
        expect = expect,
        reject = reject,
        size = size,
        tags = tags,
        **kwargs
    )

def expect_test_success_test(
        name,
        target,
        bazel_args = [],
        env = {},
        worker_sandboxing = False,
        expect = [],
        reject = [],
        size = "large",
        tags = ["local", "requires-network"],
        **kwargs):
    """Declares an `sh_test` asserting that `bazel test` of `target` succeeds.

    Same plumbing as `expect_test_failure_test`, but the nested `bazel test` is
    expected to pass. Useful for a fixture that only passes under a specific
    `--test_filter` or with an inherited env var, which this wrapper supplies via
    `bazel_args`/`env`.

    Args:
        name: test target name.
        target: label whose nested `bazel test` must succeed. A package-relative
            label (`":foo"` or `"foo"`) is resolved against this package. The
            caller must tag this fixture `"manual"`: it only passes with the
            flags this wrapper supplies, so a plain wildcard `bazel test //...`
            would run it without them and fail.
        bazel_args: extra flags forwarded verbatim to the nested `bazel test`
            (e.g. `"--test_filter=A"`).
        env: dict of KEY: VALUE exported into the nested `bazel` client env before
            the run (e.g. to feed the target's `env_inherit`).
        worker_sandboxing: see `expect_build_failure_test`.
        expect: file labels whose (newline-stripped) contents must appear in the
            output. Automatically added to the test's `data`.
        reject: file labels whose (newline-stripped) contents must NOT appear in
            the output. Automatically added to the test's `data`.
        size: test size; defaults to `"large"`.
        tags: test tags; defaults to `["local", "requires-network"]`.
        **kwargs: forwarded to the underlying `sh_test` (e.g. extra `data`).
    """
    _nested_bazel_test(
        name = name,
        command = "test",
        target = target,
        bazel_args = bazel_args,
        expect_success = True,
        env = env,
        worker_sandboxing = worker_sandboxing,
        expect = expect,
        reject = reject,
        size = size,
        tags = tags,
        **kwargs
    )
