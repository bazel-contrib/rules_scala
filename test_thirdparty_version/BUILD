load("//test/expect_build_failure:expect_build_failure.bzl", "expect_test_success_test")

# This package lives at the repo root, not under test/. test_rules_scala.sh
# runs a `test/...` wildcard for several jobs, including one that sets
# --java_language_version=21. Scala 3.1.3 fails to build under JDK 21, so
# this package must stay out of that wildcard's reach.
#
# Latest version of each major version.
# Tests for other versions belong in test_dependency_versions.sh instead.
[
    expect_test_success_test(
        name = "scala_%s" % scala_version.replace(".", "_"),
        bazel_args = [
            "--test_output=errors",
            "--repo_env=SCALA_VERSION=%s" % scala_version,
        ],
        # This nested build rebuilds the whole //third_party/... tree per
        # version, so it is too disk-heavy for the release job, same as the
        # other nested-bazel tests tagged this way.
        tags = ["no-release", "no-sandbox", "requires-network"],
        target = "//third_party/...",
    )
    for scala_version in [
        "3.9.0",  # Latest LTS 3.9 version
        "3.3.8",  # Latest LTS 3.3 version
        "3.1.3",  # First supported major for Scala 3, max supported JDK=18
        "2.13.18",
        "2.12.21",
    ]
]
