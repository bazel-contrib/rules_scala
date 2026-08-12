load(
    "//test/expect_build_failure:expect_build_failure.bzl",
    "expect_build_failure_test",
    "expect_build_success_test",
)

# Fixture lives in test_expect_failure/missing_direct_deps -- shared by this
# package and by test/shell/test_scala_binary.sh and
# test/shell/test_strict_dependency.sh (migrating separately), so it stays put
# instead of being colocated here.
_INTERNAL_DEPS = "//test_expect_failure/missing_direct_deps/internal_deps"
_EXTERNAL_DEPS = "//test_expect_failure/missing_direct_deps/external_deps"

_STRICT_DEPS_ERROR = "--extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_error"
_STRICT_DEPS_WARN = "--extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_warn"
_DIRECT_DEPS_OFF = "--extra_toolchains=//test/toolchains:high_level_direct_deps"

expect_build_failure_test(
    name = "fails_on_missing_direct_internal_dep",
    build_args = [_STRICT_DEPS_ERROR],
    expect = ["expected_missing_direct_internal_dep.txt"],
    target = _INTERNAL_DEPS + ":transitive_dependency_user",
)

expect_build_failure_test(
    name = "fails_on_missing_direct_external_jar_dep",
    build_args = [_STRICT_DEPS_ERROR],
    expect = ["expected_missing_direct_external_jar_dep.txt"],
    target = _EXTERNAL_DEPS + ":transitive_external_dependency_user",
)

expect_build_failure_test(
    name = "fails_on_missing_direct_external_file_group_dep",
    build_args = [_STRICT_DEPS_ERROR],
    expect = ["expected_missing_direct_external_file_group_dep.txt"],
    target = _EXTERNAL_DEPS + ":transitive_external_dependency_user_file_group",
)

# No --extra_toolchains override: the default toolchain has no strict-deps
# checking, so a missing direct dep is just an ordinary missing-symbol compile
# error rather than a buildozer hint.
expect_build_failure_test(
    name = "fails_on_missing_direct_dep_by_default",
    expect = ["expected_not_found_value_c.txt"],
    target = _INTERNAL_DEPS + ":transitive_dependency_user",
)

# strict_deps_mode = "warn": the build must still succeed, only the warning
# text is asserted.
expect_build_success_test(
    name = "warns_on_missing_direct_dep_in_warn_mode",
    build_args = [_STRICT_DEPS_WARN],
    expect = ["expected_missing_direct_dep_warning.txt"],
    target = _INTERNAL_DEPS + ":transitive_dependency_user",
)

expect_build_success_test(
    name = "warns_on_missing_direct_java_dep_with_strict_java_deps_warn",
    build_args = ["--strict_java_deps=warn"],
    expect = ["expected_missing_direct_java_dep.txt"],
    target = _INTERNAL_DEPS + ":transitive_dependency_java_user",
)

# --extra_toolchains=high_level_direct_deps explicitly turns strict-deps off
# (as opposed to fails_on_missing_direct_dep_by_default, which relies on it
# being off by default) -- same raw compiler error either way.
expect_build_failure_test(
    name = "fails_on_missing_direct_dep_in_off_mode",
    build_args = [_DIRECT_DEPS_OFF],
    expect = ["expected_not_found_value_c.txt"],
    target = _INTERNAL_DEPS + ":transitive_dependency_user",
)

expect_build_failure_test(
    name = "fails_on_missing_direct_java_dep_with_strict_java_deps_error",
    build_args = ["--strict_java_deps=error"],
    expect = ["expected_missing_direct_java_dep.txt"],
    target = _INTERNAL_DEPS + ":transitive_dependency_java_user",
)

# dependent_on_some_java_provider's direct dep is a custom_jvm rule wrapping
# transitive_dependency's ijar -- the buildozer hint must still name the
# scala_library target, not the ijar/jar file it produced.
expect_build_failure_test(
    name = "reports_scala_library_label_not_ijar_on_missing_transitive_dep",
    build_args = [_STRICT_DEPS_ERROR],
    expect = ["expected_transitive_dep_label_via_java_provider.txt"],
    target = _INTERNAL_DEPS + ":dependent_on_some_java_provider",
)

# Same as above, but the custom_jvm's jar has no stamped manifest to recover a
# label from, so the message instead names the jar file and the target that
# produced it.
expect_build_failure_test(
    name = "reports_label_from_other_jvm_rule_on_missing_transitive_dep",
    build_args = [_STRICT_DEPS_ERROR],
    expect = ["expected_unknown_label_from_unstamped_jar.txt"],
    target = _INTERNAL_DEPS + ":unstamped_jar_dependent_on_some_java_provider",
)
