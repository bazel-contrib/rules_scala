load("@rules_shell//shell:sh_test.bzl", "sh_test")

# Without `scala_deps.scala()`, `@rules_scala_toolchains` must contain only the
# toolchains that the module enables. The default Scala toolchain refers to
# compiler repos that `scala_deps` creates only for `scala_deps.scala()`.
sh_test(
    name = "scala_disabled_test",
    size = "large",
    srcs = ["scala_disabled_test.sh"],
    data = [
        "//:MODULE.bazel",
        "//scala:toolchains.bzl",
        "//scala:toolchains_repo.bzl",
        "//test/expect_build_failure:nested_bazel.sh",
    ],
    tags = [
        "exclusive",
        "local",
        "no-release",
        "requires-network",
    ],
)
