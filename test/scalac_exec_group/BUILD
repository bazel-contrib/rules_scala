load("@rules_shell//shell:sh_test.bzl", "sh_test")
load(
    "//scala:scala.bzl",
    "scala_binary",
    "scala_junit_test",
    "scala_library",
    "scala_library_for_plugin_bootstrapping",
    "scala_macro_library",
    "scala_repl",
    "scala_test",
)
load("//scala_proto:scala_proto.bzl", "scala_proto_library")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test")
load("//twitter_scrooge:twitter_scrooge.bzl", "scrooge_scala_library")

package(default_testonly = 1)

# Regression targets for the "scalac" exec_group. Each sets a scalac.*
# exec_property, which Bazel validates against the rule's exec_groups at
# analysis time. Removing the exec_group from a rule fails these targets.
# See docs/scalac_exec_group.md.
#
# The `manual` tag on the *_test targets keeps `bazel test //test/...`
# from executing them — they exist to be analyzed, not run.
#
# :scalac_action_exec_properties_test below additionally verifies that the
# property actually reaches the Scalac action, which catches removal of
# `exec_group = "scalac"` from ctx.actions.run in compile_scala.

_SCALAC_EXEC_GROUP_PROPS = {"scalac.cpu": "1"}

scala_library(
    name = "Lib",
    srcs = ["Lib.scala"],
    exec_properties = _SCALAC_EXEC_GROUP_PROPS,
)

scala_macro_library(
    name = "Macro",
    srcs = ["Macro.scala"],
    exec_properties = _SCALAC_EXEC_GROUP_PROPS,
)

scala_library_for_plugin_bootstrapping(
    name = "LibForPluginBootstrapping",
    srcs = ["Lib.scala"],
    exec_properties = _SCALAC_EXEC_GROUP_PROPS,
)

scala_binary(
    name = "Binary",
    srcs = ["Binary.scala"],
    exec_properties = _SCALAC_EXEC_GROUP_PROPS,
    main_class = "scalarules.test.scalac_exec_group.Binary",
    deps = [
        ":Lib",
        ":Macro",
    ],
)

scala_test(
    name = "Test",
    size = "small",
    srcs = ["LibSuite.scala"],
    exec_properties = _SCALAC_EXEC_GROUP_PROPS,
    tags = ["manual"],
    deps = [":Lib"],
)

scala_junit_test(
    name = "JunitTest",
    size = "small",
    srcs = ["LibJunitTest.scala"],
    exec_properties = _SCALAC_EXEC_GROUP_PROPS,
    suffixes = ["Test"],
    tags = ["manual"],
    deps = [":Lib"],
)

# scala_repl only invokes Scalac when srcs are present, so give this target
# a source to exercise the compile path.
scala_repl(
    name = "Repl",
    srcs = ["Lib.scala"],
    exec_properties = _SCALAC_EXEC_GROUP_PROPS,
)

# Each test below drives a nested `bazel` against the real source tree, so Bazel
# does not see the rule implementations as inputs of the test and would serve a
# cached PASS after a regression in them instead of re-running. Naming them in
# `data` is the cross-package equivalent of `code_under_test` in
# expect_build_failure.bzl, which only globs the test's own package. Each test
# names just the sources that can change its own outcome.

# The seven targets above only prove the *rules* declare the exec_group -- that
# is what analysis validates. This test additionally proves the property reaches
# the Scalac *action*; see the script for why that needs a nested `bazel aquery`
# rather than an analysistest.
sh_test(
    name = "scalac_action_exec_properties_test",
    size = "large",
    srcs = ["scalac_action_exec_properties_test.sh"],
    args = [
        # Bazel applies Bourne tokenization to `sh_test` args, which would split
        # this value on its space into two args; single-quoting keeps it whole.
        "'cpu: 1'",
        "//test/scalac_exec_group:Lib",
        "//test/scalac_exec_group:Macro",
        "//test/scalac_exec_group:LibForPluginBootstrapping",
        "//test/scalac_exec_group:Binary",
        "//test/scalac_exec_group:Test",
        "//test/scalac_exec_group:JunitTest",
        "//test/scalac_exec_group:Repl",
    ],
    data = [
        "//:MODULE.bazel",
        "//test/expect_build_failure:nested_bazel.sh",
        # compile_scala, which wires the Scalac action to the exec_group, plus
        # the rule definitions that declare it for the targets queried above.
        "//scala/private:rule_impls.bzl",
        "//scala/private:rules/scala_binary.bzl",
        "//scala/private:rules/scala_junit_test.bzl",
        "//scala/private:rules/scala_library.bzl",
        "//scala/private:rules/scala_repl.bzl",
        "//scala/private:rules/scala_test.bzl",
    ] + glob(["*"]),
    # Uses a nested output base dedicated to only this test.
    tags = [
        "exclusive",
        "local",
        "requires-network",
    ],
)

# scala_proto_library and scrooge_scala_library run Scalac via an aspect, and
# Bazel does not propagate target-level exec_properties to aspect actions. The
# top-level rules therefore intentionally do NOT declare the "scalac"
# exec_group: a user setting scalac.* here would silently drop the value, and
# the missing exec_group turns that silent drop into an analysis-time error.
# The fixtures are tagged "manual" so wildcard builds skip them.
#
# The error comes from validating exec_properties while the target is being
# configured, before the rule is analyzed, so `--allow_analysis_failures` never
# sees it and expect_analysis_failure_test cannot catch it -- hence the nested
# `bazel build` here.
scala_proto_library(
    name = "scala_proto_library_with_scalac_exec_property",
    exec_properties = _SCALAC_EXEC_GROUP_PROPS,
    tags = ["manual"],
    deps = ["//test/proto3:generated-proto-lib"],
)

scrooge_scala_library(
    name = "scrooge_scala_library_with_scalac_exec_property",
    exec_properties = _SCALAC_EXEC_GROUP_PROPS,
    tags = ["manual"],
    deps = ["//test/src/main/scala/scalarules/test/twitter_scrooge/thrift"],
)

# The message is asserted as two fragments rather than one sentence because
# Bazel reworded it: 7.x says "Tried to set properties for non-existent exec
# groups: scalac", newer versions say "Tried to set exec_properties for
# non-existent exec groups on <label>: scalac". These two fragments are what
# both wordings share, and `expect` requires every file to match, so together
# they still pin the failure to a missing exec group named scalac.
_EXPECTED_MISSING_EXEC_GROUP = [
    "expected_missing_exec_group_error.txt",
    "expected_missing_exec_group_name.txt",
]

expect_build_failure_test(
    name = "scala_proto_library_rejects_scalac_exec_property",
    expect = _EXPECTED_MISSING_EXEC_GROUP,
    no_fingerprint_reason = "the fixture is rejected while its target is configured, so it runs no action to fingerprint",
    target = ":scala_proto_library_with_scalac_exec_property",
)

expect_build_failure_test(
    name = "scrooge_scala_library_rejects_scalac_exec_property",
    expect = _EXPECTED_MISSING_EXEC_GROUP,
    no_fingerprint_reason = "the fixture is rejected while its target is configured, so it runs no action to fingerprint",
    target = ":scrooge_scala_library_with_scalac_exec_property",
)
