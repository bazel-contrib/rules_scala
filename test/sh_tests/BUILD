load("@rules_python//python:defs.bzl", "py_binary")
load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//scala:scala.bzl", "scala_test")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_test_success_test")

package(default_testonly = 1)

exports_files([
    "string_in_file.sh",
    "string_in_filename_in_jar.sh",
])

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

# --test_output=all is needed so expect/reject below can grep the test's stdout.
expect_test_success_test(
    name = "test_filter_wildcard_test",
    target = "//test:TestFilterTests",
    bazel_args = [
        "--test_output=all",
        "--test_filter=scalarules.test.*",
    ],
    expect = [
        "expected_test_filter_a.txt",
        "expected_test_filter_b.txt",
    ],
)

expect_test_success_test(
    name = "test_filter_single_test",
    target = "//test:TestFilterTests",
    bazel_args = [
        "--test_output=all",
        "--test_filter=scalarules.test.TestFilterTestA",
    ],
    expect = ["expected_test_filter_a.txt"],
    reject = ["expected_test_filter_b.txt"],
)

sh_test(
    name = "multi_service_manifest_test",
    srcs = ["multi_service_manifest_test.sh"],
    args = [
        "$(rootpath //test:ScalaBinary_with_service_manifest_srcs_deploy.jar)",
        "$(rootpath //test/example_jars:expected_service_manifest.txt)",
    ],
    data = [
        "//test:ScalaBinary_with_service_manifest_srcs_deploy.jar",
        "//test/example_jars:expected_service_manifest.txt",
    ],
)

sh_test(
    name = "repl_test",
    srcs = ["repl_test.sh"],
    args = [
        "--hello-lib-repl",
        "$(rootpath //test:HelloLibRepl)",
        "--hello-lib-test-repl",
        "$(rootpath //test:HelloLibTestRepl)",
        "--scala-lib-binary-repl",
        "$(rootpath //test:ScalaLibBinaryRepl)",
        "--resources-strip-scala-binary-repl",
        "$(rootpath //test:ResourcesStripScalaBinaryRepl)",
        "--repl-with-sources",
        "$(rootpath //test:ReplWithSources)",
    ],
    data = [
        "//test:HelloLibRepl",
        "//test:HelloLibTestRepl",
        "//test:ReplWithSources",
        "//test:ResourcesStripScalaBinaryRepl",
        "//test:ScalaLibBinaryRepl",
        # Not exercised at runtime, but its presence in `data` keeps it
        # build-checked, same as the shell original's `bazel build` over all
        # `kind(scala_repl, //test/...)` query results.
        "//test/phase/add_to_all_rules:PhaseRepl",
    ],
)
