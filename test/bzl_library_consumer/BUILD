load("@rules_shell//shell:sh_test.bzl", "sh_test")

# A consumer module must be able to run `starlark_doc_extract` on its own macro
# that loads rules_scala files, with the `bzl_library` labels that its gazelle
# guesses.
sh_test(
    name = "bzl_library_consumer_test",
    size = "large",
    srcs = ["bzl_library_consumer_test.sh"],
    data = [
        "//:MODULE.bazel",
        "//:all_bzl",
        "//test/expect_build_failure:nested_bazel.sh",
    ],
    # `external` runs the test every time, because BUILD files outside `data`
    # declare the tested labels.
    tags = [
        "external",
        "local",
        "no-release",
        "requires-network",
    ],
)
