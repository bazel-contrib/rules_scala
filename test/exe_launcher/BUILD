load("@rules_shell//shell:sh_test.bzl", "sh_test")

package(default_testonly = 1)

# The exe launcher is only built to run on Windows.
sh_test(
    name = "launcher_file_writer_test",
    size = "small",
    srcs = ["launcher_file_writer_test.sh"],
    data = ["//src/java/io/bazel/rulesscala/exe"],
    target_compatible_with = ["@platforms//os:windows"],
    deps = ["@bazel_tools//tools/bash/runfiles"],
)
