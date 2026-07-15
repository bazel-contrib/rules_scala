load("//scala:scala.bzl", "scala_test")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_test_failure_test", "expect_test_success_test")

# `inherit_a` asserts the env var `a` (declared via env_inherit) equals "b", so it
# only passes when `a=b` is present in the bazel client env. Tagged "manual" so a
# plain `bazel test //...` (without `a` set) doesn't run it. The tests below drive
# nested `bazel test` runs: one with `a=b` exported (must pass) and a negative
# control with `a` unset (must fail), so together they prove the inherited env
# actually takes effect rather than being silently ignored.
scala_test(
    name = "inherit_a",
    srcs = ["InheritedEnvTest.scala"],
    env_inherit = ["a"],
    tags = ["manual"],
)

expect_test_success_test(
    name = "inherited_environment_test",
    env = {"a": "b"},
    target = ":inherit_a",
)

# Negative control: without `a` exported, `sys.env("a")` fails to resolve, so the
# nested `bazel test` must fail.
expect_test_failure_test(
    name = "missing_environment_test",
    bazel_args = ["--test_output=errors"],
    expect = ["expected_missing_env.txt"],
    target = ":inherit_a",
)
