load(":bzlmod_macros.bzl", "bzlmod_fake_root_module_test", "bzlmod_macro_test")

bzlmod_macro_test(
    name = "single_tag_values_returns_defaults_when_no_root_tag_test",
    expect = "foo bar baz$",
    target = "//:print-single-test-tag-values",
)

bzlmod_fake_root_module_test(
    name = "creates_fake_root_module_tags_when_unused_by_root_module_test",
)

bzlmod_macro_test(
    name = "single_tag_values_returns_regular_root_tag_values_test",
    expect = "quux bar plugh$",
    tag_lines = ['test_ext.single_test_tag(first = "quux", third = "plugh")'],
    target = "//:print-single-test-tag-values",
)

bzlmod_macro_test(
    name = "single_tag_values_returns_dev_root_tag_values_test",
    expect = "quux bar plugh$",
    tag_lines = ['dev_test_ext.single_test_tag(first = "quux", third = "plugh")'],
    target = "//:print-single-test-tag-values",
)

bzlmod_macro_test(
    name = "single_tag_values_combines_regular_and_dev_dep_tags_test",
    expect = "quux xyzzy frobozz$",
    tag_lines = [
        'test_ext.single_test_tag(first = "quux", third = "plugh")',
        'dev_test_ext.single_test_tag(second = "xyzzy", third = "frobozz")',
    ],
    target = "//:print-single-test-tag-values",
)

bzlmod_macro_test(
    name = "single_tag_values_fails_if_more_than_two_tags_test",
    expect_fail = "expected one regular tag instance and/or one dev_dependency instance, got 3: 'single_test_tag' tag at {MODULE_BAZEL}:",
    tag_lines = [
        "test_ext.single_test_tag()",
        "dev_test_ext.single_test_tag()",
        'dev_test_ext.single_test_tag(second = "not", third = "happening")',
    ],
    target = "//:print-single-test-tag-values",
)

bzlmod_macro_test(
    name = "single_tag_values_fails_if_dev_tag_before_regular_test",
    expect_fail = "expected one regular tag instance and/or one dev_dependency instance, got the dev_dependency instance before the regular instance: 'single_test_tag' tag at {MODULE_BAZEL}:",
    tag_lines = [
        "dev_test_ext.single_test_tag()",
        'test_ext.single_test_tag(first = "unused")',
    ],
    target = "//:print-single-test-tag-values",
)

bzlmod_macro_test(
    name = "single_tag_values_fails_if_two_regular_tags_test",
    expect_fail = "expected one regular tag instance and/or one dev_dependency instance, got two regular instances: 'single_test_tag' tag at {MODULE_BAZEL}:",
    tag_lines = [
        'test_ext.single_test_tag(first = "of two")',
        'test_ext.single_test_tag(second = "of two")',
    ],
    target = "//:print-single-test-tag-values",
)

bzlmod_macro_test(
    name = "single_tag_values_fails_if_two_dev_tags_test",
    expect_fail = "expected one regular tag instance and/or one dev_dependency instance, got two dev_dependency instances: 'single_test_tag' tag at {MODULE_BAZEL}:",
    tag_lines = [
        'dev_test_ext.single_test_tag(first = "of two")',
        'dev_test_ext.single_test_tag(second = "of two")',
    ],
    target = "//:print-single-test-tag-values",
)

bzlmod_macro_test(
    name = "repeated_tag_values_for_zero_instances_test",
    expect = "\\{\\}$",
    target = "//:print-repeated-test-tag-values",
)

bzlmod_macro_test(
    name = "repeated_tag_values_for_one_instance_test",
    expect = '\\{"foo": \\{"required": "bar", "optional": ""\\}\\}$',
    tag_lines = ['test_ext.repeated_test_tag(unique_key = "foo", required = "bar")'],
    target = "//:print-repeated-test-tag-values",
)

bzlmod_macro_test(
    name = "repeated_tag_values_for_multiple_instances_test",
    expect = '\\{"foo": \\{"required": "bar", "optional": ""\\}, "baz": \\{"required": "quux", "optional": "xyzzy"\\}, "plugh": \\{"required": "frobozz", "optional": ""\\}\\}$',
    tag_lines = [
        'test_ext.repeated_test_tag(unique_key = "foo", required = "bar")',
        'test_ext.repeated_test_tag(unique_key = "baz", required = "quux", optional = "xyzzy")',
        'dev_test_ext.repeated_test_tag(unique_key = "plugh", required = "frobozz")',
    ],
    target = "//:print-repeated-test-tag-values",
)

bzlmod_macro_test(
    name = "repeated_tag_values_fails_on_duplicate_key_test",
    expect_fail = "multiple tags with same unique_key: 'repeated_test_tag' tag at {MODULE_BAZEL}:",
    tag_lines = [
        'test_ext.repeated_test_tag(unique_key = "foo", required = "bar")',
        'dev_test_ext.repeated_test_tag(unique_key = "foo", required = "baz")',
    ],
    target = "//:print-repeated-test-tag-values",
)
