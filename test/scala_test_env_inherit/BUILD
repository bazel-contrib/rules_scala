load("//scala:scala.bzl", "scala_test")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_test_success_test")

# `inherit_a` asserts the env var `a` (declared via env_inherit) equals "b", so it
# only passes when `a=b` is present in the bazel client env. Tagged "manual" so a
# plain `bazel test //...` (without `a` set) doesn't run it; the test below drives
# a nested `bazel test` with `a=b` exported and asserts it passes.
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
