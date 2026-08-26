load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_success_test")

package(default_testonly = 1)

expect_build_success_test(
    name = "proto_source_root",
    no_fingerprint_reason = "scala_proto compiles through an aspect of its own, whose actions collect_actions.bzl cannot read",
    target = "//test/proto_source_root/user:user_scala",
)
