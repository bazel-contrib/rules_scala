load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_success_test")

package(default_testonly = 1)

# `//test/src/main/scala/scalarules/test/classpath_resources:classpath_resource_duplicates`
# is a scala_binary with two `classpath_resources` of the same name, so it builds
# successfully but ScalacWorker prints a namespace-conflict warning. Bazel has no
# native "build and assert on output" rule, so drive a nested `bazel build` via
# expect_build_success_test and assert the warning is surfaced. (See that macro's
# docstring for how it keeps a cached action from hiding the warning.)
#
# `target` lives in another package, so its sources aren't tracked as this test's
# runfiles (see expect_build_failure.bzl) and an edit there won't force a re-run;
# the fixture is long-standing and rarely touched.
expect_build_success_test(
    name = "classpath_resource_namespace_conflict_test",
    expect = ["expected_namespace_conflict.txt"],
    target = "//test/src/main/scala/scalarules/test/classpath_resources:classpath_resource_duplicates",
)
