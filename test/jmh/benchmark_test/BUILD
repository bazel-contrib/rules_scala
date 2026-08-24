load("@rules_shell//shell:sh_test.bzl", "sh_test")

# This lives in its own package rather than //test/jmh so that //test/jmh does
# not load @rules_shell (a dev-only dependency, invisible when rules_scala is
# consumed as a module): //test/jmh:jmh_command_line_parsing_test is built by
# test_dependency_versions.sh as an external-module consumer.
sh_test(
    name = "benchmark_test",
    srcs = ["benchmark_test.sh"],
    args = ["$(rootpath //test/jmh:test_benchmark)"],
    data = ["//test/jmh:test_benchmark"],
)
