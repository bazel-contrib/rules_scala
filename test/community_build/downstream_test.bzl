"""Bazel-native downstream test: fetches a real external consumer as a
repository (see downstream_repository.bzl), then in the consumer's own
checkout, wired against *this* rules_scala checkout: first repins its Maven
lockfile(s) (`bazel run @maven//:pin`, since the consumer's exact pin may not
match a version this checkout's third_party repos carry), then runs a
nested `bazel test` against `targets`.
"""

load("@rules_shell//shell:sh_test.bzl", "sh_test")

def downstream_test(
        name,
        repo_name,
        scala_version,
        targets,
        extra_bazel_flags = "",
        size = "large",
        # TEMP (throwaway verify branch): dropped "manual" so ubuntu2004/macos
        # CI's `bazel test //...` actually picks these up for once.
        tags = ["external", "local", "requires-network"],
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
            `["manual", "external", "local", "requires-network"]`.
            `manual` keeps this out of `bazel test //...` (this repo's own CI
            tasks run that wildcard, and cloning + testing a full external
            project on every PR is slow and network-dependent). `external`
            disables test-result caching: the nested build reads this
            checkout's *live* source tree via `local_path_override`, so
            rules_scala's sources are code under test without being declared
            inputs of this `sh_test` -- a cached PASS would survive edits to
            them and go stale (the same unsound-caching trap
            `expect_build_failure_test` fixed by globbing its code under
            test, except here the code under test is the whole repo, out of
            a BUILD-file glob's reach). `local` and `requires-network` match
            `expect_build_failure_test`'s rationale -- the nested build
            fetches external repos and must run outside the sandbox.
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
        ],
        size = size,
        tags = tags,
        **kwargs
    )
