load(
    "@rules_scala//testing:testing.bzl",
    "setup_scala_testing_toolchain",
)

# This example uses the same toolchain deps you'd get from using
# `scala_toolchains(junit = True, scalatest = True, specs2 = True)`. It's a
# working example that we test via `test_examples.sh`.
setup_scala_testing_toolchain(
    name = "testing_toolchain",
    junit_classpath = [
        "@multi_frameworks_toolchain_maven//:junit_junit",
        "@multi_frameworks_toolchain_maven//:org_hamcrest_hamcrest_core",
    ],
    scalatest_classpath = [
        "@multi_frameworks_toolchain_maven//:org_scalactic_scalactic_2_12",
        "@multi_frameworks_toolchain_maven//:org_scalatest_scalatest_2_12",
        "@multi_frameworks_toolchain_maven//:org_scalatest_scalatest_compatible",
        "@multi_frameworks_toolchain_maven//:org_scalatest_scalatest_core_2_12",
        "@multi_frameworks_toolchain_maven//:org_scalatest_scalatest_featurespec_2_12",
        "@multi_frameworks_toolchain_maven//:org_scalatest_scalatest_flatspec_2_12",
        "@multi_frameworks_toolchain_maven//:org_scalatest_scalatest_freespec_2_12",
        "@multi_frameworks_toolchain_maven//:org_scalatest_scalatest_funspec_2_12",
        "@multi_frameworks_toolchain_maven//:org_scalatest_scalatest_funsuite_2_12",
        "@multi_frameworks_toolchain_maven//:org_scalatest_scalatest_matchers_core_2_12",
        "@multi_frameworks_toolchain_maven//:org_scalatest_scalatest_mustmatchers_2_12",
        "@multi_frameworks_toolchain_maven//:org_scalatest_scalatest_shouldmatchers_2_12",
    ],
    specs2_classpath = [
        "@multi_frameworks_toolchain_maven//:org_specs2_specs2_common_2_12",
        "@multi_frameworks_toolchain_maven//:org_specs2_specs2_core_2_12",
        "@multi_frameworks_toolchain_maven//:org_specs2_specs2_fp_2_12",
        "@multi_frameworks_toolchain_maven//:org_specs2_specs2_matcher_2_12",
    ],
    specs2_junit_classpath = ["@multi_frameworks_toolchain_maven//:org_specs2_specs2_junit_2_12"],
)
