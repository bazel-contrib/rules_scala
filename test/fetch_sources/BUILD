load("@rules_shell//shell:sh_test.bzl", "sh_test")

# Tests using fetch_sources_test.sh depend on `io_bazel_rules_scala_guava`
# (fetched via scala_deps(), unaffected by the rules_jvm_external migration)
# always fetching sources by default; only an explicit non-"true"
# BAZEL_JVM_FETCH_SOURCES value turns that off. See scala_maven_import_external.bzl.
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
