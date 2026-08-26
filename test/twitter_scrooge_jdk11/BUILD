load(
    "//test/expect_build_failure:expect_build_failure.bzl",
    "expect_build_success_test",
)

# Not declared in test/src/main/scala/scalarules/test/twitter_scrooge itself:
# this macro loads @rules_shell, a dev_dependency in the root MODULE.bazel,
# invisible whenever something consumes rules_scala as a non-root bzlmod
# dependency (a CI check does exactly that today, building
# :twitter_scrooge_tests directly). This package isn't part of that closure.
expect_build_success_test(
    name = "twitter_scrooge_builds_with_jdk_11",
    build_args = [
        "--java_language_version=11",
        "--tool_java_language_version=11",
        "--java_runtime_version=remotejdk_11",
        "--tool_java_runtime_version=remotejdk_11",
    ],
    # Absolute wildcard, not package-relative: _absolutize passes a "//"-prefixed
    # label through unchanged, so this reaches the nested `bazel build` as-is.
    target = "//test/src/main/scala/scalarules/test/twitter_scrooge/...",
)
