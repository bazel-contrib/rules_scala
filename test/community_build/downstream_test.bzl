"""Bazel-native downstream test: fetches a real external consumer as a
repository (see downstream_repository.bzl), then in the consumer's own
checkout, wired against *this* rules_scala checkout: first repins its Maven
lockfile(s) (`bazel run @maven//:pin`, since the consumer's exact pin may not
match a version this checkout's third_party repos carry), then runs a
nested `bazel test` against `targets`.

Cacheability
------------
The nested `bazel test` reads this checkout's *live* source tree via
`local_path_override` (see downstream_repository.bzl), not the runfiles this
`sh_test` was handed -- so rules_scala's own sources are code under test
without being declared inputs, the same unsound-caching trap
`test/expect_build_failure/expect_build_failure.bzl` fixes for its own nested
tests. `@rules_scala_source_fingerprint//:fingerprint.txt` (see
source_fingerprint.bzl) hashes every file rules_scala exposes to a downstream
consumer, so an edit anywhere in scope changes this `sh_test`'s declared
inputs and forces a re-run.

`no-sandbox` + `no-remote-exec` rather than `local`: `local` also precludes
the *local* test-result cache, not just sandboxing and remote execution (see
https://bazel.build/reference/be/common-definitions#test.tags) -- with it,
this test would never come back `(cached) PASSED` even on an unmodified rerun.
"""

load("@rules_shell//shell:sh_test.bzl", "sh_test")

def downstream_test(
        name,
        repo_name,
        scala_version,
        targets,
        extra_bazel_flags = "",
        filtered_targets = [],
        test_filter = "",
        smoke_test_targets = [],
        patches = [],
        size = "large",
        tags = ["no-sandbox", "no-remote-exec", "requires-network", "skip-last-green-bazel"],
        **kwargs):
    """Declares an `sh_test` testing `targets` in the `repo_name` external repo.

    Args:
        name: test target name.
        repo_name: name of the `downstream_consumer_repository` to test.
        scala_version: value to force via --repo_env=SCALA_VERSION (must be
            one this checkout's third_party repos carry).
        targets: list of Bazel target patterns to test in the consumer repo,
            run unfiltered in one nested `bazel test` invocation -- or, when
            `smoke_test_targets` is set, compiled in one nested `bazel build`
            invocation instead (see `smoke_test_targets`).
        extra_bazel_flags: extra flags forwarded to the nested `bazel test`
            -- or, when `smoke_test_targets` is set, to *both* the main
            `bazel build` and the separate `bazel test` for
            `smoke_test_targets`.
        filtered_targets: target patterns run only through a chosen
            ScalaTest suite (`test_filter`), instead of their whole test
            source tree -- e.g. joern_test uses this to run just a smoke
            suite for jssrc2cpg, its most expensive target, while every
            other target in `targets` keeps running unfiltered. Needs a
            *second*, separate nested `bazel test` invocation, with
            `extra_bazel_flags` plus `--test_filter=<test_filter>`: Bazel
            applies `--test_filter` uniformly across every target in one
            `bazel test` invocation, so sharing the main invocation would
            apply that same suite name to every other target too, and each
            one fails with "class not found" since the suite exists only in
            the filtered target's classpath. Exclude a filtered target from
            `targets` too (e.g. a `-//pkg/...` negative pattern), so it runs
            exactly once.
        test_filter: value forwarded as `filtered_targets`' nested `bazel
            test`'s own `--test_filter`. A separate arg from
            `extra_bazel_flags`, which stays a single `args` list element:
            rules_shell's `sh_test` re-splits that element on whitespace
            before the driver script's own `--extra-bazel-flags` parsing
            sees it, so a value like `"--test_timeout=... --test_filter=..."`
            hands the driver's arg loop a bare `--test_filter=...`, which
            only its catch-all `*)` case matches, exiting with "Unknown
            argument".
        smoke_test_targets: if set, only these targets get tested; every
            other target in `targets` only builds (see
            downstream_test_driver.sh for the mechanism). Pick one
            mechanism per target: this, or `filtered_targets`.
        patches: patch files applied to `repo_name`'s consumer in
            `MODULE.bazel` (that `consumer(...)` call's own `patches` attr).
            Declared here too, as `data`, purely for this `sh_test`'s own
            cache soundness: `source_fingerprint.bzl`'s scope stops at what
            rules_scala exposes, leaving a patch under `test/` outside it,
            so the patch content needs its own declared input to force a
            real re-run instead of reusing a stale cached PASS.
        size: test size; defaults to "large" (nested Bazel invocation, cold
            Maven/git fetch on first run).
        tags: test tags; defaults to
            `["no-sandbox", "no-remote-exec", "requires-network", "skip-last-green-bazel"]`.
            `no-sandbox` and `no-remote-exec` let this run outside the sandbox
            (the nested `bazel` reads the real source tree) while keeping it
            eligible for the test-result cache -- see the module docstring for
            why not `local`/`external`. `requires-network`: the nested build
            fetches external repos on a cache miss. `skip-last-green-bazel` excludes
            these from the last_green Bazel CI step (via `--test_tag_filters`):
            a third-party consumer isn't expected to build against an
            unreleased Bazel, so failures there are noise, not a rules_scala
            regression.
        **kwargs: forwarded to the underlying `sh_test`.
    """
    if bool(filtered_targets) != bool(test_filter):
        fail("downstream_test '%s': filtered_targets and test_filter must both be set, or both left empty" % name)

    args = [
        "--marker-rootpath",
        "$(rootpath @{}//_bazel_native_marker:marker.txt)".format(repo_name),
        "--scala-version",
        scala_version,
        "--output-base-name",
        name,
    ]
    if extra_bazel_flags:
        args += ["--extra-bazel-flags", extra_bazel_flags]
    if test_filter:
        args += ["--test-filter", test_filter]
    if filtered_targets:
        args += ["--filtered-targets"] + filtered_targets
    if smoke_test_targets:
        args += ["--smoke-test-targets"] + smoke_test_targets
    args += ["--"] + targets

    sh_test(
        name = name,
        srcs = ["//test/community_build:downstream_test_driver.sh"],
        args = args,
        data = [
            "@{}//_bazel_native_marker:marker.txt".format(repo_name),
            "//test/expect_build_failure:nested_bazel.sh",
            "@rules_scala_source_fingerprint//:fingerprint.txt",
        ] + patches,
        size = size,
        tags = tags,
        **kwargs
    )
