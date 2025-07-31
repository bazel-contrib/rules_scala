load("@rules_python//python:defs.bzl", "py_binary")
load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//scala:scala.bzl", "scala_test")

package(default_testonly = 1)

genrule(
    name = "MixJavaScalaLibTestOutputs",
    outs = ["mix_java_scala_lib_test_rule_outputs.txt"],
    cmd = "echo $(rootpaths //test:MixJavaScalaLib) > $@",
    tools = ["//test:MixJavaScalaLib"],
)

sh_test(
    name = "MixJavaScalaLibTest",
    srcs = ["test_scala_library_outputs_mixed_java_scala_jars.sh"],
    args = ["$(rootpath MixJavaScalaLibTestOutputs) MixJavaScalaLib"],
    data = ["MixJavaScalaLibTestOutputs"],
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

# Generate a file containing the rootpaths of a Scala binary.
genrule(
    name = "rootpath-script",
    srcs = ["//test:ScalaBinary"],
    outs = ["rootpath-script.out"],
    cmd = """
       rootpaths=($(rootpaths {}))
       (IFS='\n'; echo "$${{rootpaths[*]}}") | sort > $@
   """.format("//test:ScalaBinary"),
)

# Validate that the rootpaths point to both the binary
# and the JAR.
sh_test(
    name = "ScalaBinaryRootpaths",
    srcs = ["rootpaths_binary.sh"],
    args = ["$(rootpath :rootpath-script.out)"],
    data = [":rootpath-script.out"],
)

sh_test(
    name = "test_binary_run_with_large_classpath",
    srcs = ["test_binary_run_with_large_classpath.sh"],
    args = ["$(rootpath //test/src/main/scala/scalarules/test/large_classpath:largeClasspath)"],
    data = ["//test/src/main/scala/scalarules/test/large_classpath:largeClasspath"],
)

# Make sure scala_binary works in genrule environment
genrule(
    name = "ScalaBinaryInGenrule",
    outs = ["scala_binary_out.txt"],
    cmd = "$(execpath //test:ScalaBinary) > $@",
    tools = ["//test:ScalaBinary"],
)

sh_test(
    name = "TestScalaBinaryInGenrule",
    srcs = ["test_binary.sh"],
    args = ["cat $(rootpath :ScalaBinaryInGenrule)"],
    data = [":ScalaBinaryInGenrule"],
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

py_binary(
    name = "py_resource_binary",
    srcs = ["py_resource.py"],
    main = "py_resource.py",
)

scala_test(
    name = "ScalaTestResourcesFromLocalTargetTest",
    srcs = ["ScalaTestResourcesFromLocalTargetTest.scala"],
    resources = [":py_resource_binary"],
)
