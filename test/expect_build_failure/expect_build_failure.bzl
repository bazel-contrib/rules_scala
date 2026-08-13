"""Macros for asserting the outcome of a nested `bazel <command>` of a target.

Bazel has no native "run bazel and assert on the outcome" rule, so we wrap an
`sh_test` around `expect_build_failure.sh` (which runs a nested `bazel build`,
`bazel test` or `bazel coverage`). These macros let callers declare intent --
the target, the subcommand, and the messages the output must/mustn't contain --
instead of hand-assembling the script's raw args, `$(rootpath ...)` expansions,
runfiles, and boilerplate tags on every call.

- `expect_build_failure_test` asserts a `bazel build` fails.
- `expect_build_success_test` asserts a `bazel build` succeeds (e.g. a fixture
  that only builds under a specific flag or toolchain override).
- `expect_test_failure_test` asserts a `bazel test` (or `bazel coverage`) fails.
- `expect_test_success_test` asserts a `bazel test` succeeds (e.g. a fixture that
  only passes under a specific `--test_filter` or inherited env var).

All four share the same script and nested-Bazel plumbing.

A label inside a `build_args`/`bazel_args` flag value (e.g.
`--extra_toolchains=//pkg:toolchain`) is passed through as-is: unlike
`target`, it is not absolutized against the caller's package, because the
nested `bazel` runs from the workspace root. Always write such a label out in
full, even for a toolchain defined in the same package as the caller.

Cacheability
------------
The nested `bazel` builds from the git checkout on disk, not from the runfiles
the outer Bazel handed this test. So the files that decide whether the test
passes are not inputs of the test, and Bazel would serve a stale pass. These
tests therefore name those files by hand:

- the fixture's own package (globbed below); a fixture in another package is
  tagged `external`, because a macro cannot verify that caller `data` covers
  every source the nested target reads;
- the toolchains a `--extra_toolchains` flag registers, by analysing the
  fixture under them (see collect_actions.bzl);
- the repo `.bazelrc`, which CI steps append to, so two steps that differ only
  by those lines no longer share one result;
- `MODULE.bazel` and its lock, which fix the dependency versions;
- `.bazelversion`, which picks the Bazel binary the nested build runs;
- the jars of the compiler and of the test runners, because the fixture's
  command line carries their paths and not their content;
- a fingerprint of the actions the fixture and its dependencies run (see
  collect_actions.bzl). This is what makes an edit to the rules re-run the test.

Editing `.bazelversion` re-runs the tests. What that file cannot catch is a CI
step which leaves it alone and points bazelisk at another binary. One step does
that (`last_green`), and it keeps its own cache key regardless, because it
appends three flags to `.bazelrc`, which is on the list above.

Outside the list is whatever the network serves while external repositories are
fetched. `MODULE.bazel.lock` pins the versions, so what is exposed is a flaky
download rather than a silent change in what is being tested. Catching an input
nobody thought of would take a run with `--nocache_test_results` on the branch
we merge into, which means a step in `.bazelci/presubmit.yml`; this change does
not touch CI configuration.

A fixture that fails during analysis never runs an action, so there is nothing
to fingerprint and no honest cache key for it. Assert on such a target with
expect_analysis_failure_test, which asks Bazel directly.
"""

load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//test/expect_build_failure:collect_actions.bzl", "fixture_actions")

_HELPER = "//test/expect_build_failure:expect_build_failure.sh"

# Sourced at runtime by _HELPER, so it must be present in the test's runfiles.
_NESTED_BAZEL_LIB = "//test/expect_build_failure:nested_bazel.sh"

# The nested `bazel` runs the compiler this repo builds, so a change in its Java
# sources changes what the test exercises. The command line only carries the
# jar's path, so the jar itself has to be an input for its content to count.
_SCALAC_JAR = "//src/java/io/bazel/rulesscala/scalac:scalac_deploy.jar"

# The compiler jar above does not pull in the test runners, and a nested
# `bazel test` runs through them, so their content decides its outcome too.
_RUNNER_JARS = [
    "//src/java/io/bazel/rulesscala/test_discovery:test_discovery.jar",
    "//src/java/io/bazel/rulesscala/specs2:specs2_test_discovery.jar",
    "//src/java/io/bazel/rulesscala/scala_test:librunner.jar",
    "//src/java/io/bazel/rulesscala/coverage/instrumenter:instrumenter.jar",
]

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
        fingerprint_target,
        no_fingerprint_reason,
        bazel_arg_files = [],
        **kwargs):
    absolute_target = _absolutize(target)
    args = ["--command", command, "--target", absolute_target]
    if expect_success:
        args += ["--expect-success"]

        # Without a clean, a cached build can silently skip recompiling and
        # miss printing the warning we're about to check for.
        if expect or reject:
            args += ["--clean-before-build"]
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
    for bazel_arg_file in bazel_arg_files:
        # The flag's value lives in the file, so only its (metacharacter-free)
        # path rides the `sh_test` args here -- see the helper's --bazel-arg-file.
        args += ["--bazel-arg-file", "$(rootpath %s)" % bazel_arg_file]
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
    # another package is tagged `external` below.
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
    # Everything the nested `bazel` reads and this test's own key would
    # otherwise miss: the repo `.bazelrc` (CI steps append to it, so two steps
    # would otherwise share one cached result), the resolved dependency
    # versions, the Bazel version bazelisk picks, and the compiler jar.
    data = [
        "//:MODULE.bazel",
        "//:MODULE.bazel.lock",
        "//:.bazelrc",
        "//:.bazelversion",
        _SCALAC_JAR,
        _NESTED_BAZEL_LIB,
    ] + _RUNNER_JARS + expect + reject + bazel_arg_files + code_under_test + kwargs.pop("data", [])
    # The fingerprint below is taken under these, so that a change in a toolchain
    # the nested build registers re-runs the test.
    extra_toolchains = [
        arg[len("--extra_toolchains="):]
        for arg in bazel_args
        if arg.startswith("--extra_toolchains=")
    ]

    # Some nested builds run no action this aspect can read: `scala_proto`
    # generates through an aspect of its own, and a fixture that only builds
    # toolchain deps compiles nothing at all. Such a test states why and is
    # tagged `external`, which keeps it out of the cache entirely -- a test
    # without a fingerprint must not be served a stale pass.
    current_package = "//%s:" % native.package_name()
    cross_package_fixture = not absolute_target.startswith(current_package)
    if no_fingerprint_reason or cross_package_fixture:
        # The package glob above cannot cross a Bazel package boundary, and a
        # macro cannot prove that caller `data` covers every source of a target
        # or pattern. Keep cross-package results out of the cache rather than
        # serve a stale pass after an undeclared source edit.
        tags = tags + ["external"]
    else:
        # `target` may be a pattern, which has no single configured target to read
        # actions from. Rather than leave such a test without a key, ask for one
        # concrete target the pattern builds.
        fingerprint_target = fingerprint_target or target
        if "..." in fingerprint_target or fingerprint_target.endswith((":all", ":*")):
            fail("target %s is a pattern; pass fingerprint_target with one concrete label it builds, so a rules change still invalidates %s" % (target, name))
        fixture_actions(
            name = "%s_fixture_actions" % name,
            target = fingerprint_target,
            extra_toolchains = extra_toolchains,
            testonly = True,
        )
        data.append(":%s_fixture_actions" % name)

    # `no-sandbox` rather than `local`: both run the nested `bazel` outside the
    # sandbox, which is all it needs, but a `local` result is also kept out of
    # the shared cache. `no-remote-exec` because it reads this machine's tree.
    execution_tags = tags + ["exclusive", "no-remote-exec"]

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
        # `exclusive`: each runs a nested `bazel` that takes the shared output
        # base's lock, so running them one at a time keeps them off each other's
        # timeout.
        tags = execution_tags,
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
        tags = ["no-sandbox", "requires-network"],
        fingerprint_target = None,
        no_fingerprint_reason = None,
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
        tags: test tags; defaults to `["no-sandbox", "requires-network"]` because the
            nested `bazel build` fetches external repos and must run outside the
            sandbox.
        fingerprint_target: label whose actions key this test, when `target` is a
            pattern rather than one label. Defaults to `target`. Ignored when
            `target` is in another package: such a fixture is always tagged
            `external` instead (see the module docstring).
        no_fingerprint_reason: why no action fingerprint can key this test. Setting
            it tags the test `external`, so it re-runs every time instead of being
            served a result that cannot notice a change in the rules.
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
        fingerprint_target = fingerprint_target,
        no_fingerprint_reason = no_fingerprint_reason,
        **kwargs
    )

def expect_build_success_test(
        name,
        target,
        build_args = [],
        worker_sandboxing = False,
        expect = [],
        reject = [],
        size = "large",
        tags = ["no-sandbox", "requires-network"],
        fingerprint_target = None,
        no_fingerprint_reason = None,
        **kwargs):
    """Declares an `sh_test` asserting that `bazel build` of `target` succeeds.

    Same plumbing as `expect_build_failure_test`, but the nested `bazel build` is
    expected to pass. Useful for a fixture that only builds successfully with a
    specific flag or toolchain override (e.g. a rule-level override winning over
    a failing toolchain default), optionally combined with `expect`/`reject` to
    assert a warning was (or wasn't) printed. When `expect`/`reject` is given,
    the helper script runs `bazel clean` first: unlike a failure, a successful
    action can be served from the nested output base's on-disk cache on a
    later run of this same test, silently skipping recompilation (and so
    reprinting no warning).

    Args:
        name: test target name.
        target: label whose nested `bazel build` must succeed. A package-relative
            label (`":foo"` or `"foo"`) is resolved against this package. The
            caller must tag this fixture `"manual"`: it only builds successfully
            with the flags this wrapper supplies, so a plain wildcard
            `bazel build //...` would run it without them and fail.
        build_args: extra flags forwarded verbatim to the nested `bazel build`
            (e.g. `"--extra_toolchains=//some:toolchain"`).
        worker_sandboxing: see `expect_build_failure_test`.
        expect: file labels whose (newline-stripped) contents must appear in the
            build output. Automatically added to the test's `data`.
        reject: file labels whose (newline-stripped) contents must NOT appear in
            the build output. Automatically added to the test's `data`.
        size: test size; defaults to `"large"`.
        tags: test tags; defaults to `["no-sandbox", "requires-network"]`.
        fingerprint_target: label whose actions key this test, when `target` is a
            pattern rather than one label. Defaults to `target`. Ignored when
            `target` is in another package: such a fixture is always tagged
            `external` instead (see the module docstring).
        no_fingerprint_reason: why no action fingerprint can key this test. Setting
            it tags the test `external`, so it re-runs every time instead of being
            served a result that cannot notice a change in the rules.
        **kwargs: forwarded to the underlying `sh_test` (e.g. extra `data`).
    """
    _nested_bazel_test(
        name = name,
        command = "build",
        target = target,
        bazel_args = build_args,
        expect_success = True,
        env = {},
        worker_sandboxing = worker_sandboxing,
        expect = expect,
        reject = reject,
        size = size,
        tags = tags,
        fingerprint_target = fingerprint_target,
        no_fingerprint_reason = no_fingerprint_reason,
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
        tags = ["no-sandbox", "requires-network"],
        fingerprint_target = None,
        no_fingerprint_reason = None,
        **kwargs):
    """Declares an `sh_test` asserting that `bazel test`/`bazel coverage` of `target` fails.

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
        tags: test tags; defaults to `["no-sandbox", "requires-network"]`.
        fingerprint_target: label whose actions key this test, when `target` is a
            pattern rather than one label. Defaults to `target`. Ignored when
            `target` is in another package: such a fixture is always tagged
            `external` instead (see the module docstring).
        no_fingerprint_reason: why no action fingerprint can key this test. Setting
            it tags the test `external`, so it re-runs every time instead of being
            served a result that cannot notice a change in the rules.
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
        fingerprint_target = fingerprint_target,
        no_fingerprint_reason = no_fingerprint_reason,
        **kwargs
    )

def expect_test_success_test(
        name,
        target,
        command = "test",
        bazel_args = [],
        bazel_arg_files = [],
        env = {},
        worker_sandboxing = False,
        expect = [],
        reject = [],
        size = "large",
        tags = ["no-sandbox", "requires-network"],
        fingerprint_target = None,
        no_fingerprint_reason = None,
        **kwargs):
    """Declares an `sh_test` asserting that `bazel test`/`bazel coverage` of `target` succeeds.

    Same plumbing as `expect_test_failure_test`, but the nested run is expected
    to pass. Useful for a fixture that only passes under a specific
    `--test_filter`, an inherited env var, or a specific toolchain, which this
    wrapper supplies via `bazel_args`/`env`.

    Args:
        name: test target name.
        target: label whose nested run must succeed. A package-relative label
            (`":foo"` or `"foo"`) is resolved against this package. The caller
            must tag this fixture `"manual"`: it only passes with the flags
            this wrapper supplies, so a plain wildcard `bazel test //...`
            would run it without them and fail.
        command: the bazel subcommand to run; `"test"` (default) or `"coverage"`.
        bazel_args: extra flags forwarded verbatim to the nested `bazel <command>`
            (e.g. `"--test_filter=A"`, `"--extra_toolchains=//some:toolchain"`).
        bazel_arg_files: file labels each holding one extra flag as its
            (newline-stripped) contents, forwarded to the nested `bazel <command>`
            just like `bazel_args`. Use this instead of `bazel_args` for a flag
            whose value the `sh_test` args pipeline would mangle -- a space, or a
            shell metacharacter the Windows launcher's `bash -c` would interpret
            (e.g. a `--test_filter` regex containing `(`/`|`/`$`). Automatically
            added to the test's `data`.
        env: dict of KEY: VALUE exported into the nested `bazel` client env before
            the run (e.g. to feed the target's `env_inherit`).
        worker_sandboxing: see `expect_build_failure_test`.
        expect: file labels whose (newline-stripped) contents must appear in the
            output. Automatically added to the test's `data`.
        reject: file labels whose (newline-stripped) contents must NOT appear in
            the output. Automatically added to the test's `data`.
        size: test size; defaults to `"large"`.
        tags: test tags; defaults to `["no-sandbox", "requires-network"]`.
        fingerprint_target: label whose actions key this test, when `target` is a
            pattern rather than one label. Defaults to `target`. Ignored when
            `target` is in another package: such a fixture is always tagged
            `external` instead (see the module docstring).
        no_fingerprint_reason: why no action fingerprint can key this test. Setting
            it tags the test `external`, so it re-runs every time instead of being
            served a result that cannot notice a change in the rules.
        **kwargs: forwarded to the underlying `sh_test` (e.g. extra `data`).
    """
    _nested_bazel_test(
        name = name,
        command = command,
        target = target,
        bazel_args = bazel_args,
        bazel_arg_files = bazel_arg_files,
        expect_success = True,
        env = env,
        worker_sandboxing = worker_sandboxing,
        expect = expect,
        reject = reject,
        size = size,
        tags = tags,
        fingerprint_target = fingerprint_target,
        no_fingerprint_reason = no_fingerprint_reason,
        **kwargs
    )
