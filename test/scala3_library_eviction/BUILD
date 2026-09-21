load("//scala:scala.bzl", "scala_library")
load("//scala:scala_import.bzl", "scala_import")
load("//scala:scala_toolchain.bzl", "scala_toolchain")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test", "expect_build_success_test")

# A different scala3-library_3 version than :app's toolchain (3.6.4 below).
scala_import(
    name = "rogue_scala3_library",
    jars = ["@io_bazel_rules_scala_scala_library_3_7_4//:scala3-library_3-3.7.4.jar"],
)

# scala_import runs no scalac action, so this puts the rogue jar two hops
# below :app without also compiling anything at the wrong version.
scala_import(
    name = "third_party_stub",
    jars = ["@com_google_guava_guava_21_0//:guava-21.0.jar"],
    deps = [":rogue_scala3_library"],
)

scala_library(
    name = "app",
    srcs = ["App.scala"],
    scala_version = "3.6.4",
    tags = ["manual"],
    deps = [":third_party_stub"],
)

# Mimics rules_jvm_external's jvm_import, which names its compile jar
# "header_" + the original basename -- what maven_install deps put on the classpath.
genrule(
    name = "header_prefixed_rogue_jar",
    srcs = ["@io_bazel_rules_scala_scala_library_3_7_4//:scala3-library_3-3.7.4.jar"],
    outs = ["header_scala3-library_3-3.7.4.jar"],
    cmd = "cp $< $@",
)

scala_import(
    name = "rogue_scala3_library_header_prefixed",
    jars = [":header_prefixed_rogue_jar"],
)

scala_import(
    name = "third_party_stub_header_prefixed",
    jars = ["@com_google_guava_guava_21_0//:guava-21.0.jar"],
    deps = [":rogue_scala3_library_header_prefixed"],
)

scala_library(
    name = "app_header_prefixed",
    srcs = ["App.scala"],
    scala_version = "3.6.4",
    tags = ["manual"],
    deps = [":third_party_stub_header_prefixed"],
)

# Same version as the toolchain's own scala3-library_3 -- must not trip the check.
scala_import(
    name = "same_version_scala3_library",
    jars = ["@io_bazel_rules_scala_scala_library_3_6_4//:scala3-library_3-3.6.4.jar"],
)

scala_import(
    name = "third_party_stub_same_version",
    jars = ["@com_google_guava_guava_21_0//:guava-21.0.jar"],
    deps = [":same_version_scala3_library"],
)

scala_library(
    name = "app_same_version_stdlib",
    srcs = ["App.scala"],
    scala_version = "3.6.4",
    tags = ["manual"],
    deps = [":third_party_stub_same_version"],
)

# scala3-library_3 matches (3.6.4) on both chains; only scala-library differs.
scala_import(
    name = "rogue_scala_library_only",
    jars = ["@io_bazel_rules_scala_scala_library_2_12_21//:scala-library-2.12.21.jar"],
)

scala_import(
    name = "third_party_stub_scala_library_only",
    jars = ["@com_google_guava_guava_21_0//:guava-21.0.jar"],
    deps = [":rogue_scala_library_only"],
)

scala_library(
    name = "app_scala_library_only_mismatch",
    srcs = ["App.scala"],
    scala_version = "3.6.4",
    tags = ["manual"],
    deps = [":third_party_stub_scala_library_only"],
)

scala_toolchain(
    name = "transitive_impl",
    dependency_mode = "transitive",
    strict_deps_mode = "off",
    unused_dependency_checker_mode = "off",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "transitive",
    toolchain = ":transitive_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_toolchain(
    name = "direct_impl",
    dependency_mode = "direct",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "direct",
    toolchain = ":direct_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

scala_toolchain(
    name = "plusone_impl",
    dependency_mode = "plus-one",
    visibility = ["//visibility:public"],
)

toolchain(
    name = "plusone",
    toolchain = ":plusone_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

expect_build_failure_test(
    name = "transitive_deps_mode_rejects_mismatched_stdlib_test",
    build_args = ["--extra_toolchains=//test/scala3_library_eviction:transitive"],
    expect = ["expected_mismatch_error.txt"],
    no_fingerprint_reason = ":app fails during analysis under this toolchain (that's what this test asserts), so fixture_actions cannot analyse it to read its command lines",
    target = ":app",
)

expect_build_failure_test(
    name = "plus_one_deps_mode_rejects_mismatched_stdlib_test",
    build_args = ["--extra_toolchains=//test/scala3_library_eviction:plusone"],
    expect = ["expected_mismatch_error.txt"],
    no_fingerprint_reason = ":app fails during analysis under this toolchain (that's what this test asserts), so fixture_actions cannot analyse it to read its command lines",
    target = ":app",
)

expect_build_success_test(
    name = "direct_deps_mode_ignores_transitive_stdlib_mismatch_test",
    build_args = ["--extra_toolchains=//test/scala3_library_eviction:direct"],
    target = ":app",
)

expect_build_failure_test(
    name = "transitive_deps_mode_rejects_header_prefixed_mismatched_stdlib_test",
    build_args = ["--extra_toolchains=//test/scala3_library_eviction:transitive"],
    expect = ["expected_mismatch_error.txt"],
    no_fingerprint_reason = ":app_header_prefixed fails during analysis under this toolchain (that's what this test asserts), so fixture_actions cannot analyse it to read its command lines",
    target = ":app_header_prefixed",
)

expect_build_success_test(
    name = "transitive_deps_mode_ignores_same_version_stdlib_test",
    build_args = ["--extra_toolchains=//test/scala3_library_eviction:transitive"],
    target = ":app_same_version_stdlib",
)

expect_build_failure_test(
    name = "transitive_deps_mode_rejects_mismatched_scala_library_alone_test",
    build_args = ["--extra_toolchains=//test/scala3_library_eviction:transitive"],
    expect = ["expected_scala_library_mismatch_error.txt"],
    no_fingerprint_reason = ":app_scala_library_only_mismatch fails during analysis under this toolchain (that's what this test asserts), so fixture_actions cannot analyse it to read its command lines",
    target = ":app_scala_library_only_mismatch",
)
