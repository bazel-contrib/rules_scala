load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//scala:scala.bzl", "scala_library_suite")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_failure_test")

# `scala_library_suite` compiles each source into its own independent
# `scala_library` (one source file each, with no dependency on its siblings) and
# then aggregates them under a meta target that exports them all. Consequently a
# source that references a symbol defined in a sibling source fails to compile:
# the sibling is not on that child library's classpath. The suite therefore only
# supports mutually independent sources; interdependent files must instead go in
# a plain `scala_library` (which compiles them together). This asserts the
# unsupported case is rejected -- DependsOnSibling.scala references Sibling.
scala_library_suite(
    name = "library_suite_dep_on_children",
    srcs = [
        "DependsOnSibling.scala",
        "Sibling.scala",
    ],
    tags = ["manual"],
)

expect_build_failure_test(
    name = "scala_library_suite_dep_on_children_build_test",
    expect = ["expected_dep_on_sibling.txt"],
    target = ":library_suite_dep_on_children",
)

# A scala_library_suite with a source that does not compile at all (DataA.scala
# is deliberately not valid Scala) must likewise fail to build.
scala_library_suite(
    name = "library_suite_with_invalid_source",
    srcs = glob(["Data*.scala"]),
    tags = ["manual"],
)

expect_build_failure_test(
    name = "scala_library_suite_invalid_source_build_test",
    target = ":library_suite_with_invalid_source",
)

# The fingerprint that keys the test above has to reach the actions of the
# fixture's *dependencies*: a suite compiles in its children and only merges
# their jars, so a fingerprint of the suite target alone carries no Scalac
# command line and a rules change would not invalidate anything.
sh_test(
    name = "fingerprint_reaches_dependency_actions",
    srcs = ["//test/sh_tests:string_in_file.sh"],
    args = [
        "true",
        "Scalac",
        "$(rootpath :scala_library_suite_dep_on_children_build_test_fixture_actions)",
    ],
    data = [":scala_library_suite_dep_on_children_build_test_fixture_actions"],
)
