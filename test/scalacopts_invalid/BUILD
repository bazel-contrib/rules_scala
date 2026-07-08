# `//test_expect_failure/scalacopts_invalid:empty` is a `scala_library` with an
# invalid `-source:not-existing` scalacopt, so it is expected to fail to build.
# Bazel has no native "expect build failure" rule, so each test drives a nested
# `bazel build` (per Scala version) via expect_build_failure_test and asserts the
# compiler error is surfaced cleanly (no raw `ScalacWorker` stack trace).

load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test")

package(default_testonly = 1)

_TARGET = "//test_expect_failure/scalacopts_invalid:empty"

[
    expect_build_failure_test(
        name = "invalid_scalacopts_%s" % scala_version.replace(".", "_"),
        build_args = ["--repo_env=SCALA_VERSION=%s" % scala_version],
        expect = [
            version_specific_message,
            "expected_failed_to_invoke.txt",
        ],
        reject = ["rejected_scalacworker_stacktrace.txt"],
        target = _TARGET,
    )
    for scala_version, version_specific_message in [
        ("2.12.21", "expected_bad_option.txt"),
        ("2.13.18", "expected_bad_option.txt"),
        ("3.3.8", "expected_not_valid_choice.txt"),
    ]
]
