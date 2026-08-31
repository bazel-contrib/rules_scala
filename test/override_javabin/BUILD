load("@rules_shell//shell:sh_test.bzl", "sh_test")

package(default_testonly = 1)

# JAVABIN is a bash-only mechanism, read by the launcher scala_binary/
# scala_test generate (see phase_write_executable.bzl); Windows uses a
# native .exe launcher, so this test is meaningless there.
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
