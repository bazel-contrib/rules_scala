load("@rules_shell//shell:sh_test.bzl", "sh_test")

# These tests create a standalone Bazel module that consumes rules_scala through
# local_path_override, matching how an external bzlmod consumer sees its module
# extensions. The fake-root case also creates a second module around the first.
_NESTED_BAZEL_DATA = [
    "//:.bazelrc",
    "//:.bazelversion",
    "//:MODULE.bazel",
    "//:MODULE.bazel.lock",
    "//:deps/latest/MODULE.bazel",
    "//scala/private:macros/bzlmod.bzl",
    "//test/expect_build_failure:nested_bazel.sh",
    ":BUILD.bzlmod_test",
    ":MODULE.bzlmod_test",
    ":MODULE.bzlmod_test_root_module",
    ":bzlmod_test_ext.bzl",
]

_NESTED_BAZEL_TAGS = [
    "exclusive",
    "local",
    "requires-network",
]

[
    sh_test(
        name = name,
        size = "large",
        srcs = ["bzlmod_macros_test.sh"],
        args = ["--case=%s" % case],
        data = _NESTED_BAZEL_DATA,
        tags = _NESTED_BAZEL_TAGS,
    )
    for name, case in [
        ("single_tag_values_returns_defaults_when_no_root_tag_test", "single-tag-defaults"),
        ("creates_fake_root_module_tags_when_unused_by_root_module_test", "fake-root-module-tags"),
        ("single_tag_values_returns_regular_root_tag_values_test", "single-tag-regular-root-values"),
        ("single_tag_values_returns_dev_root_tag_values_test", "single-tag-dev-root-values"),
        ("single_tag_values_combines_regular_and_dev_dep_tags_test", "single-tag-combines-regular-and-dev"),
        ("single_tag_values_fails_if_more_than_two_tags_test", "single-tag-fails-if-more-than-two-tags"),
        ("single_tag_values_fails_if_dev_tag_before_regular_test", "single-tag-fails-if-dev-tag-before-regular"),
        ("single_tag_values_fails_if_two_regular_tags_test", "single-tag-fails-if-two-regular-tags"),
        ("single_tag_values_fails_if_two_dev_tags_test", "single-tag-fails-if-two-dev-tags"),
        ("repeated_tag_values_for_zero_instances_test", "repeated-tag-values-for-zero-instances"),
        ("repeated_tag_values_for_one_instance_test", "repeated-tag-values-for-one-instance"),
        ("repeated_tag_values_for_multiple_instances_test", "repeated-tag-values-for-multiple-instances"),
        ("repeated_tag_values_fails_on_duplicate_key_test", "repeated-tag-values-fails-on-duplicate-key"),
    ]
]
