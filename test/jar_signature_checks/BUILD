load("@rules_python//python:defs.bzl", "py_binary")
load("@rules_shell//shell:sh_test.bzl", "sh_test")

package(default_testonly = 1)

exports_files(
    [
        "string_in_file.sh",
        "string_in_filename_in_jar.sh",
    ],
    visibility = [
        "//test/phase/adjustment:__pkg__",
        "//test/phase/add_to_all_rules:__pkg__",
        "//test/src/main/scala/scalarules/test/resources:__pkg__",
        "//test/src/main/scala/scalarules/test/twitter_scrooge/strings:__pkg__",
    ],
)

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

# Checks that string_in_filename_in_jar.sh (which tests for a filename inside
# a jar) itself fails loudly when its inputs are bad, instead of reporting a
# false pass.
sh_test(
    name = "string_in_filename_in_jar_required_failures",
    size = "small",
    srcs = ["string_in_filename_in_jar_required_failures.sh"],
    args = [
        "$(rootpath string_in_filename_in_jar.sh)",
        "thrift/thrift_with_compiler_args/thrift5_scrooge_java.jar",
        "$(rootpaths //test/src/main/scala/scalarules/test/twitter_scrooge:justscrooges_java)",
    ],
    data = [
        "string_in_filename_in_jar.sh",
        "//test/src/main/scala/scalarules/test/twitter_scrooge:justscrooges_java",
    ],
)

# Checks that string_in_file.sh itself fails loudly when it can't read the
# file, instead of reporting a false pass.
sh_test(
    name = "string_in_file_required_failures",
    size = "small",
    srcs = ["string_in_file_required_failures.sh"],
    args = ["$(rootpath string_in_file.sh)"],
    data = ["string_in_file.sh"],
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
