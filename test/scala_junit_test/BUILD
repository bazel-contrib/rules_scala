load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//scala:scala.bzl", "scala_junit_test", "scala_specs2_junit_test")
load("//test/expect_build_failure:expect_analysis_failure.bzl", "expect_analysis_failure_test")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_test_failure_test", "expect_test_success_test")

# The discovery/filter/xml tests below depend on //test:Junit* fixtures (which
# are testonly), so mark the whole package testonly.
package(default_testonly = 1)

# These scala_junit_test fixtures are each expected to fail when run, so they are
# tagged "manual" (a failing test would break wildcard `bazel test //...`); the
# expect_test_failure_test targets drive a nested `bazel test` and assert it fails.

# A JUnit test whose method throws must report a test failure.
scala_junit_test(
    name = "failing_test",
    size = "small",
    srcs = ["JunitFailureTest.scala"],
    suffixes = ["Test"],
    tags = ["manual"],
)

# A scala_junit_test must declare a class prefix or suffix; without one it fails.
scala_junit_test(
    name = "no_prefix_or_suffix",
    size = "small",
    srcs = ["JunitTest.scala"],
    tags = ["manual"],
)

# A suffix that matches no class must error with "no tests found".
scala_junit_test(
    name = "no_tests_found",
    size = "small",
    srcs = ["JunitTest.scala"],
    suffixes = ["DoesNotMatch"],
    tags = ["manual"],
)

expect_test_failure_test(
    name = "failing_test_fails",
    target = ":failing_test",
)

expect_analysis_failure_test(
    name = "no_prefix_or_suffix_fails",
    message = "Setting at least one of the attributes ('prefixes','suffixes') is required",
    target_under_test = ":no_prefix_or_suffix",
)

expect_test_failure_test(
    name = "no_tests_found_fails",
    target = ":no_tests_found",
)

# A specs2 suite whose class cannot be instantiated. Tagged "manual" (it fails
# when run); the tests below drive nested `bazel test` runs and assert the
# specs2 UserException surfaces.
scala_specs2_junit_test(
    name = "specs2_failing_test",
    size = "small",
    srcs = [
        "specs2/FailingTest.scala",
        "specs2/SuiteWithOneFailingTest.scala",
    ],
    suffixes = ["Test"],
    tags = ["manual"],
)

# Without a filter the failing spec's initializer throws; the run must fail with
# the specs2 UserException.
expect_test_failure_test(
    name = "specs2_exception_in_initializer_fails",
    bazel_args = [
        "--nocache_test_results",
        "--test_output=streamed",
    ],
    expect = ["expected_specs2_user_exception.txt"],
    target = ":specs2_failing_test",
)

# Filtering to the failing spec must surface the same exception and terminate
# promptly (no test-timeout), i.e. the run fails fast rather than hanging.
expect_test_failure_test(
    name = "specs2_exception_terminates_without_timeout",
    bazel_args = [
        "--nocache_test_results",
        "--test_output=streamed",
        "--test_timeout=10",
        "--test_filter=scalarules.test.junit.specs2.FailingTest#",
    ],
    expect = ["expected_specs2_user_exception.txt"],
    reject = ["rejected_timeout.txt"],
    target = ":specs2_failing_test",
)

# The tests below assert on which JUnit classes/methods a `scala_junit_test`
# discovers and runs. The signal is the runner's own stdout (the
# `print_discovered_classes` listing and each test method's `println`), so they
# drive a nested `bazel test ... --test_output=all` and match on that output. The
# fixtures live in //test; each is added to `data` only so editing its sources
# re-keys the wrapping test (the nested `bazel` reads the real source tree, so
# the fixture is otherwise invisible to this test's cache key).

# `suffixes` selects every discovered class whose name ends with one of them.
expect_test_success_test(
    name = "multiple_junit_suffixes_test",
    bazel_args = [
        "--test_output=all",
        "--nocache_test_results",
    ],
    data = ["//test:JunitMultipleSuffixes"],
    expect = [
        "discovered_classes.txt",
        "junit_suffix_it.txt",
        "junit_suffix_e2e.txt",
    ],
    target = "//test:JunitMultipleSuffixes",
)

# `prefixes` selects every discovered class whose name starts with one of them.
expect_test_success_test(
    name = "multiple_junit_prefixes_test",
    bazel_args = [
        "--test_output=all",
        "--nocache_test_results",
    ],
    data = ["//test:JunitMultiplePrefixes"],
    expect = [
        "discovered_classes.txt",
        "test_junit_custom_prefix.txt",
        "other_custom_prefix_junit.txt",
    ],
    target = "//test:JunitMultiplePrefixes",
)

# `prefixes` and `suffixes` together: a class matching either is discovered.
expect_test_success_test(
    name = "multiple_junit_patterns_test",
    bazel_args = [
        "--test_output=all",
        "--nocache_test_results",
    ],
    data = ["//test:JunitPrefixesAndSuffixes"],
    expect = [
        "discovered_classes.txt",
        "test_junit_custom_prefix.txt",
        "junit_suffix_e2e.txt",
    ],
    target = "//test:JunitPrefixesAndSuffixes",
)

# `--test_filter` narrows a run to specific methods: only the four listed run
# (their `println` appears), and no other method of the three classes does. The
# filter's regex (`(`, `|`, `$`) would be mangled by the Windows sh launcher's
# `bash -c` if it rode the args list, so it's passed via a file (bazel_arg_files).
expect_test_success_test(
    name = "junit_test_filter_test",
    bazel_arg_files = ["junit_test_filter_flags.txt"],
    bazel_args = [
        "--test_output=all",
        "--nocache_test_results",
    ],
    data = ["//test:JunitFilterTest"],
    expect = [
        "first_filter_test_method1.txt",
        "first_filter_test_method2.txt",
        "second_filter_test_method2.txt",
        "second_filter_test_method3.txt",
    ],
    reject = [
        "first_filter_test_method3.txt",
        "second_filter_test_method1.txt",
        "third_filter_test_method1.txt",
        "third_filter_test_method2.txt",
        "third_filter_test_method3.txt",
    ],
    target = "//test:JunitFilterTest",
)

# `--test_filter` also works when the class carries a custom `@RunWith` runner.
expect_test_success_test(
    name = "junit_test_filter_custom_runner_test",
    bazel_args = [
        "--test_output=all",
        "--nocache_test_results",
        "--test_filter=scalarules.test.junit.JunitCustomRunnerTest#",
    ],
    data = ["//test:JunitCustomRunner"],
    target = "//test:JunitCustomRunner",
)

# Unlike the checks above, this one asserts on the generated JUnit test.xml
# report -- an on-disk artifact `bazel test` never prints to stdout -- so it
# can't reuse the stdout-matching expect_build_failure.bzl macros. Instead it
# runs a nested `bazel test` and greps the report directly (mirroring
# test/diagnostics_reporter, which likewise runs bazel then inspects its output).
sh_test(
    name = "junit_generates_xml_logs_test",
    size = "large",
    srcs = ["junit_generates_xml_logs_test.sh"],
    data = [
        "//:MODULE.bazel",
        "//test:JunitTestWithDeps",
        "//test/expect_build_failure:nested_bazel.sh",
    ],
    tags = [
        "exclusive",
        "local",
        "requires-network",
    ],
)
