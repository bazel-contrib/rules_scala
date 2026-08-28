load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//scala:scala.bzl", "scala_test")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_test_success_test")

package(default_testonly = 1)

# //test:EnvAttributeBinary shares its TEST_ENV/HelloLib/test_vars setup with
# other tests in that package, so it stays there; referenced here by absolute
# label instead of being moved.
sh_test(
    name = "scala_binary_env_attribute_expansion_test",
    size = "large",
    srcs = ["scala_binary_env_attribute_expansion_test.sh"],
    args = [
        "//test:EnvAttributeBinary",
        "$(rootpath :expected_run_output.txt)",
    ],
    data = [
        ":expected_run_output.txt",
        "//:MODULE.bazel",
        "//test:EnvAttributeBinary",
        "//test/expect_build_failure:nested_bazel.sh",
    ],
    tags = [
        "local",
        "requires-network",
    ],
)

scala_test(
    name = "EnvAttributeManualTest",
    size = "small",
    srcs = ["EnvAttributeManualTest.scala"],
    env = {
        "FROM_TEST_ENV_AND_ENV_ATTR": "env attribute value",
        "FROM_ENV_INHERIT_AND_ENV_ATTR": "env attribute value",
        "FROM_ALL_SOURCES": "env attribute value",
    },
    env_inherit = [
        "FROM_ENV_INHERIT",
        "FROM_ENV_INHERIT_AND_ENV_ATTR",
        "FROM_ENV_INHERIT_AND_TEST_ENV",
        "FROM_ALL_SOURCES",
    ],
    tags = ["manual"],
)

expect_test_success_test(
    name = "env_attribute_precedence_test",
    bazel_args = [
        "--test_env=FROM_TEST_ENV=test env value",
        "--test_env=FROM_TEST_ENV_AND_ENV_ATTR=test env value",
        "--test_env=FROM_ENV_INHERIT_AND_TEST_ENV=test env value",
        "--test_env=FROM_ALL_SOURCES=test env value",
    ],
    env = {
        "FROM_ENV_INHERIT": "inherited value",
        "NOT_IN_ENV_INHERIT": "inherited value",
        "FROM_ENV_INHERIT_AND_ENV_ATTR": "inherited value",
        "FROM_ENV_INHERIT_AND_TEST_ENV": "inherited value",
        "FROM_ALL_SOURCES": "inherited value",
    },
    target = ":EnvAttributeManualTest",
)
