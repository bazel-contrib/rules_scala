load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//scala:scala.bzl", "scala_doc", "scala_library")
load("//scala:scala_import.bzl", "scala_import")
load("//test/expect_build_failure:expect_build_failure.bzl", "expect_build_success_test")
load("scaladoc.bzl", "scala_doc_intransitive")

package(default_testonly = 1)

# Scala_library with no deps
scala_library(
    name = "A",
    srcs = ["A.scala"],
    deps = [],
)

# B depends on A
scala_library(
    name = "B",
    srcs = ["B.scala"],
    deps = ["A"],
)

# "Simulate" A & B as imported libraries (no srcs attribute)
scala_import(
    name = "ImportedA",
    jars = ["A"],
)

scala_import(
    name = "ImportedB",
    jars = ["B"],
    deps = ["ImportedA"],
)

# scala_library with transitive external dep on ImportedB (via its deps chain to A)
# This fixture only builds successfully with --extra_toolchains, so tag it manual.
scala_library(
    name = "C",
    srcs = ["C.scala"],
    deps = [
          "ImportedB",
          # Don't include ImportedA directly; verify transitive loading works
      ],
    tags = ["manual"],
)

# scaladoc_transitive uses scala_doc (default transitive behavior) to collect docs for B and its dep A.
scala_doc(
    name = "scaladoc_transitive",
    deps = ["B"],
)

# scaladoc_intransitive uses scala_doc_intransitive (no transitive deps) so only B is documented.
scala_doc_intransitive(
    name = "scaladoc_intransitive",
    deps = ["B"],
)

# Manual fixture that only builds with --extra_toolchains flag
scala_doc(
    name = "scaladoc_C",
    deps = ["C"],
    tags = ["manual"],
)

# Test that scaladoc for transitive deps generates docs for both B and A.
sh_test(
    name = "transitive_scaladoc_test",
    size = "large",
    srcs = ["scaladoc_test.sh"],
    args = [
         "--target=//test/scaladoc:scaladoc_transitive",
         "--expect-file=B$$.html",
         "--expect-file=A$$.html"
    ],
    data = [
         "//:MODULE.bazel",
         "//test/expect_build_failure:nested_bazel.sh"
    ],
    tags = ["local", "requires-network"],
)

# Test that scaladoc for intransitive deps generates docs only for B (not A).
sh_test(
    name = "intransitive_scaladoc_test",
    size = "large",
    srcs = ["scaladoc_test.sh"],
    args = [
         "--target=//test/scaladoc:scaladoc_intransitive",
         "--expect-file=B$$.html",
         "--reject-file=A$$.html"
    ],
    data = [
         "//:MODULE.bazel",
         "//test/expect_build_failure:nested_bazel.sh"
    ],
    tags = ["local", "requires-network"],
)

# Test that scaladoc for transitive external deps works (just build succeeds).
expect_build_success_test(
    name = "scaladoc_C_build_test",
    target = "//test/scaladoc:scaladoc_C",
    build_args = ["--extra_toolchains=//test/toolchains:ast_plus_one_deps_unused_deps_warn"],
)
