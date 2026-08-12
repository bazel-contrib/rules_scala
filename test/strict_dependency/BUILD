load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test", "expect_build_success_test")

# The fixtures these tests build (test_expect_failure/missing_direct_deps/
# {internal_deps,external_deps}, test_expect_failure/plus_one_deps) are left in
# place rather than colocated: they're also referenced by the not-yet-migrated
# test_scala_library.sh and test_scala_binary.sh, so moving them here would
# break those. Once both migrate, re-check whether these are still referenced
# elsewhere before colocating them as a follow-up.

expect_build_success_test(
    name = "plus_one_deps_only_works_for_java_info_targets_test",
    build_args = ["--extra_toolchains=//test_expect_failure/plus_one_deps:plus_one_deps"],
    target = "//test/proto:test_proto",
)

expect_build_failure_test(
    name = "internal_deps_strict_deps_error_test",
    build_args = ["--extra_toolchains=//test/toolchains:ast_plus_one_deps_strict_deps_error"],
    expect = ["expected_internal_deps_strict_deps_error.txt"],
    target = "//test_expect_failure/missing_direct_deps/internal_deps:transitive_dependency_user",
)

expect_build_failure_test(
    name = "internal_deps_minimal_direct_source_deps_test",
    build_args = ["--extra_toolchains=//scala:minimal_direct_source_deps"],
    expect = ["expected_internal_deps_strict_deps_error.txt"],
    target = "//test_expect_failure/missing_direct_deps/internal_deps:transitive_dependency_user",
)

expect_build_success_test(
    name = "internal_deps_strict_deps_warn_test",
    build_args = ["--extra_toolchains=//test/toolchains:ast_plus_one_deps_strict_deps_warn"],
    expect = ["expected_internal_deps_strict_deps_warn.txt"],
    target = "//test_expect_failure/missing_direct_deps/internal_deps:transitive_dependency_user",
)

# The stamped label names a bzlmod module-extension repo (not exposed via
# use_repo at the root, unlike the plain com_google_guava_guava_21_0 case
# below), so its canonical name's separator ("~" vs "+") and the repo's own
# version suffix aren't a fixed string across the Bazel-version matrix this
# suite runs under -- hence expect_regex, not expect.
expect_build_failure_test(
    name = "external_deps_stamped_label_test",
    build_args = ["--extra_toolchains=//test/toolchains:ast_plus_one_deps_unused_deps_error"],
    expect_regex = ["expected_regex_external_deps_stamped_label.txt"],
    target = "//test_expect_failure/missing_direct_deps/external_deps:java_lib_with_a_transitive_external_dep",
)
