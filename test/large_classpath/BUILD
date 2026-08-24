load("@rules_shell//shell:sh_test.bzl", "sh_test")

package(default_testonly = 1)

sh_test(
    name = "test_binary_run_with_large_classpath",
    srcs = ["test_binary_run_with_large_classpath.sh"],
    args = ["$(rootpath //test/src/main/scala/scalarules/test/large_classpath:largeClasspath)"],
    data = ["//test/src/main/scala/scalarules/test/large_classpath:largeClasspath"],
)
