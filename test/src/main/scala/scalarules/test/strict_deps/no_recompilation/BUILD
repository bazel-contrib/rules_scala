load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//scala:scala.bzl", "scala_library")

package(default_visibility = ["//visibility:public"])

scala_library(
    name = "transitive_dependency_user",
    srcs = [
        "A.scala",
    ],
    deps = ["direct_dependency"],
)

scala_library(
    name = "direct_dependency",
    srcs = [
        "B.scala",
    ],
    deps = ["transitive_dependency"],
)

scala_library(
    name = "transitive_dependency",
    srcs = [
        "C.scala",
    ],
)

# Regression test for the ijar/interface-jar correctness contract: an
# internal-only change to `transitive_dependency`'s sources must not force a
# rebuild of `transitive_dependency_user`, under the toolchain that treats
# transitive deps of high-level rules as strict-deps errors.
sh_test(
    name = "transitive_dependency_no_recompilation_test",
    size = "large",
    srcs = ["//test/expect_build_failure:no_recompilation_test.sh"],
    args = [
        "--target=//test/src/main/scala/scalarules/test/strict_deps/no_recompilation/...",
        "--changed-file=test/src/main/scala/scalarules/test/strict_deps/no_recompilation/C.scala",
        "--search-word=orig",
        "--replace-word=altered",
        "--not-expected=test/src/main/scala/scalarules/test/strict_deps/no_recompilation:transitive_dependency_user",
        "--extra-toolchain=//test/toolchains:high_level_transitive_deps_strict_deps_error",
    ],
    data = [
        "C.scala",
        "//:MODULE.bazel",
        "//test/expect_build_failure:nested_bazel.sh",
    ],
    tags = [
        "exclusive",
        "local",
        "requires-network",
    ],
)
