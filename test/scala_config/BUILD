load("@rules_shell//shell:sh_test.bzl", "sh_test")

# The three tests below share one nested output base (see
# `nested_bazel_setup`'s own doc comment), so they must serialize rather than
# extract their own ~1GB Scala dependency tree each.
sh_test(
    name = "classpath_contains_scala_library_2_12_test",
    size = "large",
    srcs = ["classpath_contains_scala_library_test.sh"],
    args = [
        "2.12.21",
        "scala-library-2.12",
    ],
    data = [
        "//:MODULE.bazel",
        "//test/expect_build_failure:nested_bazel.sh",
        "//third_party/repositories:scala_2_12.bzl",
    ],
    tags = [
        "exclusive",
        "local",
        "requires-network",
    ],
)

sh_test(
    name = "classpath_contains_scala_library_2_13_test",
    size = "large",
    srcs = ["classpath_contains_scala_library_test.sh"],
    args = [
        "2.13.18",
        "scala-library-2.13",
    ],
    data = [
        "//:MODULE.bazel",
        "//test/expect_build_failure:nested_bazel.sh",
        "//third_party/repositories:scala_2_13.bzl",
    ],
    tags = [
        "exclusive",
        "local",
        "requires-network",
    ],
)

sh_test(
    name = "scala_config_content_test",
    size = "large",
    srcs = ["scala_config_content_test.sh"],
    data = [
        "//:MODULE.bazel",
        "//:scala_config.bzl",
        "//test/expect_build_failure:nested_bazel.sh",
    ],
    tags = [
        "exclusive",
        "local",
        "requires-network",
    ],
)
