load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//scala:scala.bzl", "scala_library", "scala_macro_library")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test")

package(default_testonly = 1)

scala_library(
    name = "incorrect-macro",
    srcs = ["IdentityMacro.scala"],
)

scala_macro_library(
    name = "correct-macro",
    srcs = ["IdentityMacro.scala"],
)

scala_library(
    name = "incorrect-macro-user",
    srcs = ["MacroUser.scala"],
    tags = ["manual"],
    deps = [":incorrect-macro"],
)

scala_library(
    name = "correct-macro-user",
    srcs = ["MacroUser.scala"],
    deps = [":correct-macro"],
)

scala_library(
    name = "macro-dependency",
    srcs = ["MacroDependency.scala"],
)

scala_macro_library(
    name = "macro-with-dependencies",
    srcs = ["MacroWithDependencies.scala"],
    deps = [":macro-dependency"],
)

scala_library(
    name = "macro-with-dependencies-user",
    srcs = ["MacroWithDependenciesUser.scala"],
    # Without this, `:macro-dependency` will be flagged as an unused dependency. But we want to test that despite it
    # appearing before `:macro-with-dependencies` in `deps`, its runtime JAR is included before its compile JAR in the
    # compile classpath
    unused_dependency_checker_mode = "off",
    deps = [
        ":macro-dependency",
        ":macro-with-dependencies",
    ],
)

# Issue #1819: when a scala_library exports a scala_macro_library, consumers only see
# the ijar on the compile classpath. Ijar strips macro implementations, causing
# ClassFormatError during macro expansion on Scala 2.x.
scala_library(
    name = "macro-exporter",
    exports = [":correct-macro"],
)

scala_library(
    name = "macro-export-user",
    srcs = ["MacroExportUser.scala"],
    deps = [":macro-exporter"],
)

build_test(
    name = "correct_macro_user_build_test",
    size = "medium",
    targets = [":correct-macro-user"],
)

build_test(
    name = "macro_with_dependencies_user_build_test",
    size = "medium",
    targets = [":macro-with-dependencies-user"],
)

# Regression test for https://github.com/bazel-contrib/rules_scala/issues/1819:
# a consumer of a scala_library that exports a scala_macro_library must still
# compile (the exported macro must not be reduced to an ijar).
build_test(
    name = "macro_export_user_build_test",
    size = "medium",
    targets = [":macro-export-user"],
)

expect_build_failure_test(
    name = "incorrect_macro_user_build_test",
    expect = [":incorrect_macro_user_expected_error.txt"],
    target = "//test/macros:incorrect-macro-user",
)

# Regression test for https://github.com/bazel-contrib/rules_scala/issues/1819:
# scala_macro_library must not emit an ijar, since ijar strips the macro
# implementations that consumers need at compile time. Checked across the
# Scala 2.x versions where ijar interpolation applies.
sh_test(
    name = "scala_macro_library_no_ijar_test",
    size = "large",
    srcs = ["expect_no_ijar.sh"],
    args = [
        "//test/macros:correct-macro",
        "test/macros/correct-macro-ijar.jar",
        "2.12.21",
        "2.13.18",
    ],
    data = [
        "//:MODULE.bazel",
        "//test/expect_build_failure:nested_bazel.sh",
    ],
    tags = [
        "local",
        "requires-network",
    ],
)

# Migrated from test/shell/test_persistent_worker.sh
# (test_persistent_worker_handles_exception_in_macro_invocation and
# test_persistent_worker_handles_stack_overflow_exception).
#
# These macros throw during expansion (a plain exception, and a StackOverflowError).
# The Scalac persistent worker must surface a clean build failure rather than
# crashing, so the sh_tests assert the build fails with the expected message and
# WITHOUT the "---8<---" worker-crash marker. The fixtures are tagged "manual" so
# wildcard `bazel build //...` skips them.
scala_macro_library(
    name = "bad_macro",
    srcs = ["BadMacro.scala"],
    tags = ["manual"],
)

scala_library(
    name = "bad_macro_invocation",
    srcs = ["BadMacroInvocation.scala"],
    tags = ["manual"],
    deps = [":bad_macro"],
)

scala_library(
    name = "stack_overflow_macro_invocation",
    srcs = ["StackOverflowMacroInvocation.scala"],
    tags = ["manual"],
    deps = [":bad_macro"],
)

expect_build_failure_test(
    name = "bad_macro_invocation_worker_build_test",
    build_args = ["--strategy=Scalac=worker"],
    expect = ["expected_macro_expansion_failure.txt"],
    reject = ["rejected_worker_crash.txt"],
    target = "//test/macros:bad_macro_invocation",
    worker_sandboxing = True,
)

expect_build_failure_test(
    name = "stack_overflow_macro_invocation_worker_build_test",
    build_args = ["--strategy=Scalac=worker"],
    expect = ["expected_stack_overflow_failure.txt"],
    reject = ["rejected_worker_crash.txt"],
    target = "//test/macros:stack_overflow_macro_invocation",
    worker_sandboxing = True,
)
