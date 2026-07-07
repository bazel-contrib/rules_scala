load("//scala:scala.bzl", "scala_library")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test")

# Migrated from test/shell/test_javac_jvm_flags.sh and
# test/shell/test_scalac_jvm_flags.sh.
#
# Each library sets an intentionally broken JVM flag (-Xmx1M, or an args-file
# flag that must be `$(location ...)`-expanded) so compilation fails. The
# fixtures are tagged "manual" so wildcard `bazel build //...` skips them; the
# sh_tests drive a nested `bazel build` and assert the failure. The "expand"
# cases additionally assert the args.txt location was expanded into the flag.

exports_files(["args.txt"])

scala_library(
    name = "can_configure_jvm_flags_for_scalac",
    srcs = ["WillNotCompileScalaSinceXmxTooLow.scala"],
    scalac_jvm_flags = ["-Xmx1M"],
    tags = ["manual"],
)

scala_library(
    name = "can_configure_jvm_flags_for_javac",
    srcs = ["WillNotCompileJavaSinceXmxTooLow.java"],
    javac_jvm_flags = ["-Xmx1M"],
    tags = ["manual"],
)

scala_library(
    name = "can_configure_jvm_flags_for_javac_via_javacopts",
    srcs = ["WillNotCompileJavaSinceXmxTooLow.java"],
    javacopts = ["-Xmx1M"],
    tags = ["manual"],
)

scala_library(
    name = "can_expand_jvm_flags_for_scalac",
    srcs = ["WillNotCompileScalaSinceXmxTooLow.scala"],
    data = [":args.txt"],
    scalac_jvm_flags = ["--made_up_flag_to_expand=$(location :args.txt)"],
    tags = ["manual"],
)

scala_library(
    name = "can_expand_jvm_flags_for_javac",
    srcs = ["WillNotCompileJavaSinceXmxTooLow.java"],
    data = [":args.txt"],
    javac_jvm_flags = ["$(location :args.txt)"],
    tags = ["manual"],
)

scala_library(
    name = "can_expand_jvm_flags_for_javac_via_javacopts",
    srcs = ["WillNotCompileJavaSinceXmxTooLow.java"],
    data = [":args.txt"],
    javacopts = ["$(location :args.txt)"],
    tags = ["manual"],
)

[
    expect_build_failure_test(
        name = name + "_build_test",
        target = "//test/toolchains/compilers_jvm_flags:" + name,
    )
    for name in [
        "can_configure_jvm_flags_for_scalac",
        "can_configure_jvm_flags_for_javac",
        "can_configure_jvm_flags_for_javac_via_javacopts",
    ]
]

[
    expect_build_failure_test(
        name = name + "_build_test",
        build_args = ["--verbose_failures"],
        expect = [message],
        target = "//test/toolchains/compilers_jvm_flags:" + name,
    )
    for name, message in [
        ("can_expand_jvm_flags_for_scalac", "expected_scalac_expand.txt"),
        ("can_expand_jvm_flags_for_javac", "expected_javac_expand.txt"),
        ("can_expand_jvm_flags_for_javac_via_javacopts", "expected_javac_expand.txt"),
    ]
]
