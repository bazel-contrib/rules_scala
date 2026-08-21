load("@rules_shell//shell:sh_test.bzl", "sh_test")

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
