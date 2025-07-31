load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//jmh:jmh.bzl", "scala_benchmark_jmh")

scala_benchmark_jmh(
    name = "test_jmh_jdk8",
    srcs = ["TestJmhRuntimeJdk8.scala"],
    runtime_jdk = select({
        "@bazel_tools//src/conditions:darwin": "@remote_jdk8_macos//:jdk",
        "@bazel_tools//src/conditions:windows": "@remote_jdk8_windows//:jdk",
        "//conditions:default": "@remote_jdk8_linux//:jdk",
    }),
)

scala_benchmark_jmh(
    name = "test_jmh_jdk11",
    srcs = ["TestJmhRuntimeJdk11.scala"],
    runtime_jdk = "@rules_java//toolchains:remote_jdk11",
)

[sh_test(
    name = "Run" + "".join([binary[idx] if binary[idx].isalnum() else "_" for idx in range(len(binary))]),
    srcs = ["test_binary.sh"],
    args = ["$(rootpath %s)" % binary],
    data = [binary if (":" in binary) else (":%s" % binary)],
) for binary in [
    ":test_jmh_jdk8",
    ":test_jmh_jdk11",
]]
