load("@rules_shell//shell:sh_test.bzl", "sh_test")

# rules_scala doesn't support argfiles on Windows yet.
sh_test(
    name = "argument_file_in_runner_test",
    size = "large",
    srcs = ["argument_file_in_runner_test.sh"],
    data = [
        "//:.bazelrc",
        "//:.bazelversion",
        "//:MODULE.bazel",
        "//:MODULE.bazel.lock",
        "//test/expect_build_failure:nested_bazel.sh",
        "//test/src/main/scala/scalarules/test/large_classpath:largeClasspath",
    ],
    tags = [
        "exclusive",
        # The nested build also reads the use_argument_file_in_runner toolchain
        # straight from the real workspace, which isn't practical to declare as
        # a source input, so caching is disabled to avoid serving a stale pass
        # after that toolchain changes.
        "external",
        "local",
        "requires-network",
    ],
    target_compatible_with = select({
        "@platforms//os:windows": ["@platforms//:incompatible"],
        "//conditions:default": [],
    }),
)
