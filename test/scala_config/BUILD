load("@rules_shell//shell:sh_test.bzl", "sh_test")

# The scalac Javac action must carry the scala-library matching the configured
# SCALA_VERSION. Same check, once per major version, off one parameterised script.
[
    sh_test(
        name = "scalac_javac_uses_scala_library_%s_test" % suffix,
        size = "large",
        srcs = ["scalac_javac_scala_library_test.sh"],
        args = [
            scala_version,
            expected_library,
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
    for suffix, scala_version, expected_library in [
        ("2_12", "2.12.21", "scala-library-2.12"),
        ("2_13", "2.13.18", "scala-library-2.13"),
    ]
]

# A fake SCALA_VERSION must flow through into the generated @rules_scala_config
# config.bzl.
sh_test(
    name = "config_bzl_reflects_scala_version_test",
    size = "large",
    srcs = ["config_bzl_reflects_scala_version_test.sh"],
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
