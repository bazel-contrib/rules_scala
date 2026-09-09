load("//test/expect_build_failure:expect_build_failure.bzl", "expect_test_success_test")

# Kept outside test/, whose wildcard test_rules_scala.sh sweeps under extra
# toolchains and under --java_language_version=21: Scala 3.1.3 only supports
# JDK up to 18 and fails to build there.
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
