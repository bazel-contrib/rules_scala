load("@rules_shell//shell:sh_test.bzl", "sh_test")

package(default_testonly = 1)

# Make sure scala_binary works in genrule environment
genrule(
    name = "ScalaBinaryInGenrule",
    outs = ["scala_binary_out.txt"],
    cmd = "$(execpath //test:ScalaBinary) > $@",
    tools = ["//test:ScalaBinary"],
)

sh_test(
    name = "TestScalaBinaryInGenrule",
    srcs = ["//test/binary_smoke:test_binary.sh"],
    args = ["cat $(rootpath :ScalaBinaryInGenrule)"],
    data = [":ScalaBinaryInGenrule"],
)
