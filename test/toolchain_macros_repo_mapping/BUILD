load("@rules_shell//shell:sh_test.bzl", "sh_test")

# `setup_scala_testing_toolchain` must work from a consumer module that does
# not `use_repo(scala_config, "rules_scala_config")`. The signal is the
# analysis outcome of a synthesized consumer module, not an in-repo build/test
# outcome, so this is a bespoke sh_test, mirroring test/scala_config.
sh_test(
    name = "consumer_repo_mapping_test",
    size = "large",
    srcs = ["consumer_repo_mapping_test.sh"],
    data = [
        "//:MODULE.bazel",
        "//test/expect_build_failure:nested_bazel.sh",
        # The macro under test; editing it must re-run this test.
        "//testing:testing.bzl",
    ],
    tags = [
        "exclusive",
        "local",
        "requires-network",
    ],
)
