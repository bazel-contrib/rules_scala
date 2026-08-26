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
        "//test/scala_library_suite:__pkg__",
        "//test/src/main/scala/scalarules/test/resources:__pkg__",
        "//test/src/main/scala/scalarules/test/twitter_scrooge/strings:__pkg__",
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
