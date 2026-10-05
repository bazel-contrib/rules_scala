load("@rules_shell//shell:sh_test.bzl", "sh_test")

# `io_bazel_rules_scala_guava` is one of the scala_proto toolchain's artifacts,
# which scala_toolchains() always fetches with sources, so its source jar is
# present unless BAZEL_JVM_FETCH_SOURCES is set to anything other than "true"
# (case insensitive). See scala_maven_import_external.bzl.
sh_test(
    name = "fetched_by_default_test",
    size = "large",
    srcs = ["fetch_sources_test.sh"],
    args = ["--expect-exists=true"],
    data = [
        "//:MODULE.bazel",
        "//test/expect_build_failure:nested_bazel.sh",
    ],
    tags = [
        "exclusive",
        "local",
        "no-release",
        "requires-network",
    ],
)

sh_test(
    name = "fetched_when_env_var_true_test",
    size = "large",
    srcs = ["fetch_sources_test.sh"],
    args = [
        "--env-value=TruE",  # the value is case insensitive
        "--expect-exists=true",
    ],
    data = [
        "//:MODULE.bazel",
        "//test/expect_build_failure:nested_bazel.sh",
    ],
    tags = [
        "exclusive",
        "local",
        "no-release",
        "requires-network",
    ],
)

sh_test(
    name = "not_fetched_when_env_var_non_true_test",
    size = "large",
    srcs = ["fetch_sources_test.sh"],
    args = [
        "--env-value=false",
        "--expect-exists=false",
    ],
    data = [
        "//:MODULE.bazel",
        "//test/expect_build_failure:nested_bazel.sh",
    ],
    tags = [
        "exclusive",
        "local",
        "no-release",
        "requires-network",
    ],
)

sh_test(
    name = "not_fetched_when_env_var_invalid_test",
    size = "large",
    srcs = ["fetch_sources_test.sh"],
    args = [
        "--env-value=1",  # anything other than "true" (case insensitive) is treated as false
        "--expect-exists=false",
    ],
    data = [
        "//:MODULE.bazel",
        "//test/expect_build_failure:nested_bazel.sh",
    ],
    tags = [
        "exclusive",
        "local",
        "no-release",
        "requires-network",
    ],
)
