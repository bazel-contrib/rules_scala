load("@rules_shell//shell:sh_test.bzl", "sh_test")

package(default_testonly = 1)

# JAVABIN is read by the bash launcher scala_binary/scala_test generate
# (see phase_java_wrapper.bzl); on Windows Bazel uses a native .exe launcher
# instead, which does not consult it, so this test is meaningless there.
sh_test(
    name = "scala_binary_override_javabin_test",
    size = "small",
    srcs = ["scala_binary_override_javabin_test.sh"],
    args = ["$(rootpath //test:ScalaBinary)"],
    data = ["//test:ScalaBinary"],
    target_compatible_with = select({
        "@platforms//os:windows": ["@platforms//:incompatible"],
        "//conditions:default": [],
    }),
)
