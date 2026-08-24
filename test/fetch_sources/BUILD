load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//scala:scala.bzl", "scala_library")

scala_library(
    name = "fetch_sources",
    testonly = True,
    srcs = ["FetchSources.scala"],
    deps = ["@com_google_guava_guava_21_0//jar"],
)

# Tests using fetch_sources_test.sh depend upon `fetch_sources` being set for
# `com_google_guava_guava_21_0` in `scala/private/extensions/dev_deps.bzl`;
# without that, `fetched_by_default_test` would fail regardless of the env var.
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
        "requires-network",
    ],
)
