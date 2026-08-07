load(
    "//test/expect_build_failure:expect_build_failure.bzl",
    "expect_build_success_test",
)

# Not declared in test/src/main/scala/scalarules/test/twitter_scrooge itself:
# that package's :twitter_scrooge_tests is built directly (as a non-root bzlmod
# dependency) by test_dependency_versions.sh, where rules_shell -- a
# dev_dependency in the root MODULE.bazel -- is invisible. Loading this
# macro's `@rules_shell` reference from that package broke that job. This
# package is not part of that consumer target closure.
expect_build_success_test(
    name = "twitter_scrooge_builds_with_jdk_11",
    build_args = [
        "--java_language_version=11",
        "--tool_java_language_version=11",
        "--java_runtime_version=remotejdk_11",
        "--tool_java_runtime_version=remotejdk_11",
    ],
    # The built target's sources live in another package, so the macro's
    # automatic glob of this package doesn't cover them for staleness. Depend
    # on a public target that transitively covers most of that package's
    # scrooge sources (:twitter_scrooge_tests itself is package-private) so a
    # source change still invalidates this test's cache key.
    data = ["//test/src/main/scala/scalarules/test/twitter_scrooge:justscrooges_scala_and_java"],
    # Absolute wildcard, not package-relative: _absolutize passes a "//"-prefixed
    # label through unchanged, so this reaches the nested `bazel build` as-is.
    target = "//test/src/main/scala/scalarules/test/twitter_scrooge/...",
)
