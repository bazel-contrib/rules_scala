load("@rules_shell//shell:sh_test.bzl", "sh_test")

package(default_testonly = 1)

exports_files(
    ["test_binary.sh"],
    visibility = ["//test/binary_in_genrule:__pkg__"],
)

# Make sure scala_binary works in test environment
[sh_test(
    name = "Run" + "".join([binary[idx] if binary[idx].isalnum() else "_" for idx in range(len(binary))]),
    srcs = ["test_binary.sh"],
    args = ["$(rootpath %s)" % binary],
    data = [binary if (":" in binary) else (":%s" % binary)],
) for binary in [
    "//test:JavaBinary",
    "//test:JavaBinary2",
    "//test:JavaOnlySources",
    "//test:MixJavaScalaLibBinary",
    "//test:MixJavaScalaSrcjarLibBinary",
    "//test:ScalaBinary",
    "//test:ScalaLibBinary",
    "//test:ResourcesStripScalaBinary",
    "//test:ScalaBinary_dependent_on_binary_with_java",
    "//test/src/main/scala/scalarules/test/classpath_resources:classpath_resource",
    "//test/src/main/scala/scalarules/test/twitter_scrooge:justscrooges",
    "//test/src/main/scala/scalarules/test/twitter_scrooge:barethrifts",
    "//test/src/main/scala/scalarules/test/twitter_scrooge:twodeep_binary",
    "//test/src/main/scala/scalarules/test/twitter_scrooge:justscrooge2b_binary",
    "//test/src/main/scala/scalarules/test/large_classpath:largeClasspath",
    "//test:test_scala_proto_server",
    "//test:scala_binary_jdk_11",
]]
