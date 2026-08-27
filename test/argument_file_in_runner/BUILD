load("@rules_shell//shell:sh_test.bzl", "sh_test")

# rules_scala doesn't support argfiles on Windows yet.
sh_test(
    name = "argument_file_in_runner_test",
    size = "large",
    srcs = ["argument_file_in_runner_test.sh"],
    data = [
        "//:MODULE.bazel",
        "//test/expect_build_failure:nested_bazel.sh",
        "//test/src/main/scala/scalarules/test/large_classpath:largeClasspath",
    ],
    tags = [
        "exclusive",
        "local",
        "requires-network",
    ],
    target_compatible_with = select({
        "@platforms//os:windows": ["@platforms//:incompatible"],
        "//conditions:default": [],
    }),
)
