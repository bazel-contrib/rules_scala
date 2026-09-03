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
        size = "large",
        tags = ["no-sandbox", "no-remote-exec", "requires-network", "skip-last-green-bazel"],
        **kwargs):
    """Declares an `sh_test` testing `targets` in the `repo_name` external repo.

    Args:
        name: test target name.
        repo_name: name of the `downstream_consumer_repository` to test.
        scala_version: value to force via --repo_env=SCALA_VERSION (must be
            one this checkout's third_party repos carry).
        targets: list of Bazel target patterns to test in the consumer repo.
        extra_bazel_flags: extra flags forwarded to the nested `bazel test`.
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
    sh_test(
        name = name,
        srcs = ["//test/community_build:downstream_test_driver.sh"],
        args = [
            "--marker-rootpath",
            "$(rootpath @{}//_bazel_native_marker:marker.txt)".format(repo_name),
            "--scala-version",
            scala_version,
            "--output-base-name",
            name,
        ] + (["--extra-bazel-flags", extra_bazel_flags] if extra_bazel_flags else []) + [
            "--",
        ] + targets,
        data = [
            "@{}//_bazel_native_marker:marker.txt".format(repo_name),
            "//test/expect_build_failure:nested_bazel.sh",
            "@rules_scala_source_fingerprint//:fingerprint.txt",
        ],
        size = size,
        tags = tags,
        **kwargs
    )
