load("@rules_shell//shell:sh_test.bzl", "sh_test")

package(default_testonly = 1)

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
