load("@rules_python//python:defs.bzl", "py_binary")
load("@rules_shell//shell:sh_test.bzl", "sh_test")

package(default_testonly = 1)

py_binary(
    name = "jar_lister",
    srcs = ["jar_lister.py"],
)

sh_test(
    name = "no_sig",
    srcs = ["no_sigs.sh"],
    args = [
        "$(rootpath :jar_lister)",
        "$(rootpath //test:ScalaBinary_with_fake_deploy.jar)",
    ],
    data = [
        ":jar_lister",
        "//test:ScalaBinary_with_fake_deploy.jar",
    ],
)

genrule(
    name = "fake_signed_jar",
    srcs = ["fake_signature.txt"],
    outs = ["fake_signed.jar"],
    cmd = "$(execpath @bazel_tools//tools/zip:zipper) c $@ META-INF/FOO.RSA=$(execpath fake_signature.txt)",
    tools = ["@bazel_tools//tools/zip:zipper"],
)

sh_test(
    name = "no_sig_required_failures",
    srcs = ["no_sigs_required_failures.sh"],
    args = [
        "$(rootpath no_sigs.sh)",
        "$(rootpath :jar_lister)",
        "$(rootpath :fake_signed_jar)",
    ],
    data = [
        "no_sigs.sh",
        ":fake_signed_jar",
        ":jar_lister",
    ],
)
