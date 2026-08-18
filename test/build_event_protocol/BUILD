load("@rules_shell//shell:sh_test.bzl", "sh_test")

# Each rule's output jar must be announced in the Build Event Protocol. Same
# check, once per rule kind, off one parameterised script; all share one nested
# output base (they are `exclusive`, so they serialize rather than multiply the
# ~1GB of extracted Scala jars a separate base would cost).
[
    sh_test(
        name = "%s_jar_exposed_in_bep_test" % name,
        size = "large",
        srcs = ["jar_exposed_in_bep_test.sh"],
        args = [
            "//test:%s" % target,
            "test/%s.jar" % jar,
        ],
        data = [
            "//:MODULE.bazel",
            "//test/expect_build_failure:nested_bazel.sh",
        ],
        tags = [
            "exclusive",
            "local",
            "requires-network",
        ],
    )
    for name, target, jar in [
        ("scala_binary", "ScalaLibBinary", "ScalaLibBinary"),
        ("scala_test", "HelloLibTest", "HelloLibTest"),
        ("scala_junit_test", "JunitTestWithDeps", "JunitTestWithDeps"),
        ("scala_binary_java", "MixJavaScalaBinary", "MixJavaScalaBinary_java"),
        ("scala_library_java", "MixJavaScalaLib", "MixJavaScalaLib_java"),
        ("scala_test_java", "MixJavaScalaScalaTest", "MixJavaScalaScalaTest_java"),
        ("junit_test_java", "MixJavaScalaJunitTest", "MixJavaScalaJunitTest_java"),
    ]
]
