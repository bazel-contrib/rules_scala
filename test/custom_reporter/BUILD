load("@rules_shell//shell:sh_test.bzl", "sh_test")

# The scala_test under test is testonly, and it rides this test's `data` (below).
package(default_testonly = 1)

# Bazel has no native "run bazel, then assert on its output artifacts" rule, and
# the signal here -- the custom reporter's `custom_reporter_check` marker file --
# is written to the test's undeclared outputs on disk, never to stdout, so this
# can't reuse the stdout-matching expect_build_failure.bzl macros. It runs a
# nested `bazel test` and inspects the marker directly (mirroring
# test/diagnostics_reporter, which likewise runs bazel then inspects its output).
sh_test(
    name = "custom_reporter_writes_check_file_test",
    size = "large",
    srcs = ["custom_reporter_writes_check_file_test.sh"],
    # //test/scala_test:custom_reporter is exercised by the nested `bazel test`,
    # which reads the real source tree; it rides `data` only so editing its
    # sources re-keys this test (it is otherwise invisible to the cache key).
    data = [
        "//:MODULE.bazel",
        "//test/expect_build_failure:nested_bazel.sh",
        "//test/scala_test:custom_reporter",
    ],
    tags = [
        "local",
        "requires-network",
    ],
)
