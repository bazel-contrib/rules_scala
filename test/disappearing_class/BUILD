load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "uses_class",
    srcs = ["UsesClass.scala"],
    deps = [":class_provider"],
)

scala_library(
    name = "class_provider",
    srcs = ["ClassProvider.scala"],
)

sh_test(
    name = "disappearing_class_test",
    size = "large",
    srcs = ["disappearing_class_test.sh"],
    args = [
        "//test/disappearing_class:uses_class",
        "test/disappearing_class/ClassProvider.scala",
        "test/disappearing_class/ClassProviderWithoutClass.scala",
    ],
    data = [
        "ClassProvider.scala",
        "ClassProviderWithoutClass.scala",
        "UsesClass.scala",
        "//:MODULE.bazel",
        "//test/expect_build_failure:nested_bazel.sh",
    ],
    tags = [
        "local",
        "requires-network",
    ],
)
