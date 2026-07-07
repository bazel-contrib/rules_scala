load("//scala:scala.bzl", "scala_library")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test")

# Migrated from test/shell/test_scala_library.sh
# (test_scala_library_expect_failure_on_java_in_src_jar_when_disabled).

# Pack the Java source into a source jar so scala_library sees a `.srcjar` input
# (rather than committing a binary jar into the repo).
genrule(
    name = "java_source_jar_srcjar",
    srcs = ["JavaSource.java"],
    outs = ["JavaSourceJar.srcjar"],
    cmd = "$(location @bazel_tools//tools/zip:zipper) c $@ JavaSource.java=$(location JavaSource.java)",
    tools = ["@bazel_tools//tools/zip:zipper"],
)

# A scala_library with expect_java_output = False must reject Java sources found
# inside a source jar. The fixture is tagged "manual" so wildcard builds skip
# it; the sh_test drives a nested `bazel build` and asserts the failure message.
scala_library(
    name = "java_source_jar",
    srcs = ["JavaSourceJar.srcjar"],
    expect_java_output = False,
    tags = ["manual"],
)

expect_build_failure_test(
    name = "java_in_src_jar_when_disabled_build_test",
    expect = ["expected_java_in_srcjar.txt"],
    target = "//test/java_in_src_jar:java_source_jar",
)
