load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//scala:scala.bzl", "scala_library")

package(default_visibility = ["//visibility:public"])

scala_library(
    name = "user",
    srcs = [
        "A.scala",
    ],
    deps = ["dependency"],
)

scala_library(
    name = "dependency",
    srcs = [
        "B.scala",
        "C.java",
    ],
)

# Regression tests for the ijar/interface-jar correctness contract: an
# internal-only change to part of `dependency`'s sources must not force a
# rebuild of its Scala consumer `user` (which only ever compiles against
# `dependency`'s interface jar) or of `dependency`'s own Java sibling sources.
# All 3 mutate real source files under the same nested output base, so
# they're tagged "exclusive" to avoid racing on the same files.
sh_test(
    name = "no_recompilation_on_internal_change_of_scala_dependency_test",
    size = "large",
    srcs = ["//test/expect_build_failure:no_recompilation_test.sh"],
    args = [
        "--target=//test/src/main/scala/scalarules/test/ijar/...",
        "--changed-file=test/src/main/scala/scalarules/test/ijar/B.scala",
        "--sed-expr='s/println(\"orig\")/println(\"altered\")/'",
        "--not-expected=test/src/main/scala/scalarules/test/ijar:user",
    ],
    data = [
        "B.scala",
        "//:MODULE.bazel",
        "//test/expect_build_failure:nested_bazel.sh",
    ],
    tags = [
        "exclusive",
        "local",
        "requires-network",
    ],
)

sh_test(
    name = "no_recompilation_on_internal_change_of_java_dependency_test",
    size = "large",
    srcs = ["//test/expect_build_failure:no_recompilation_test.sh"],
    args = [
        "--target=//test/src/main/scala/scalarules/test/ijar/...",
        "--changed-file=test/src/main/scala/scalarules/test/ijar/C.java",
        "--sed-expr='s/System.out.println(\"orig\")/System.out.println(\"altered\")/'",
        "--not-expected=test/src/main/scala/scalarules/test/ijar:user",
    ],
    data = [
        "C.java",
        "//:MODULE.bazel",
        "//test/expect_build_failure:nested_bazel.sh",
    ],
    tags = [
        "exclusive",
        "local",
        "requires-network",
    ],
)

sh_test(
    name = "no_java_recompilation_on_internal_change_of_scala_sibling_test",
    size = "large",
    srcs = ["//test/expect_build_failure:no_recompilation_test.sh"],
    args = [
        "--target=//test/src/main/scala/scalarules/test/ijar/...",
        "--changed-file=test/src/main/scala/scalarules/test/ijar/B.scala",
        "--sed-expr='s/println(\"orig_sibling\")/println(\"altered_sibling\")/'",
        "--not-expected=test/src/main/scala/scalarules/test/ijar/dependency_java",
    ],
    data = [
        "B.scala",
        "//:MODULE.bazel",
        "//test/expect_build_failure:nested_bazel.sh",
    ],
    tags = [
        "exclusive",
        "local",
        "requires-network",
    ],
)
