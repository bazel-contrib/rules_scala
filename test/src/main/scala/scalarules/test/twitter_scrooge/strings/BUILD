load("@rules_shell//shell:sh_test.bzl", "sh_test")

_PARENT = "//test/src/main/scala/scalarules/test/twitter_scrooge"

_JUSTSCROOGES = _PARENT + ":justscrooges"

_JUSTSCROOGES_JAVA = _PARENT + ":justscrooges_java"

sh_test(
    name = "libthrift2_a_not_on_classpath",
    srcs = ["string_in_file.sh"],
    args = [
        "false",
        "libthrift2_a",
        "$(rootpath %s)" % _JUSTSCROOGES,
    ],
    data = [_JUSTSCROOGES],
)

sh_test(
    name = "java_jar_not_on_classpath",
    srcs = ["string_in_file.sh"],
    args = [
        "false",
        "_java.jar",
        "$(rootpath %s)" % _JUSTSCROOGES,
    ],
    data = [_JUSTSCROOGES],
)

sh_test(
    name = "java_jar_on_classpath_in_scrooges",
    srcs = ["string_in_file.sh"],
    args = [
        "true",
        "_java.jar",
        "$(rootpath %s)" % _JUSTSCROOGES_JAVA,
    ],
    data = [_JUSTSCROOGES_JAVA],
)

sh_test(
    name = "thrift999_in_namespace_in_java_jar",
    srcs = ["string_in_filename_in_jar.sh"],
    args = [
        "true",
        "thrift/thrift_with_compiler_args/thrift5_scrooge_java.jar",
        "thrift999",
        "$(rootpaths %s)" % _JUSTSCROOGES_JAVA,
    ],
    data = [_JUSTSCROOGES_JAVA],
)

sh_test(
    name = "thrift5_not_in_namespace_in_java_jar",
    srcs = ["string_in_filename_in_jar.sh"],
    args = [
        "false",
        "thrift/thrift_with_compiler_args/thrift5_scrooge_java.jar",
        "thrift5",
        "$(rootpaths %s)" % _JUSTSCROOGES_JAVA,
    ],
    data = [_JUSTSCROOGES_JAVA],
)
