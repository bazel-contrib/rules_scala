"""The packages under scala/, src/, third_party/ that a downstream consumer's
`local_path_override` (see downstream_repository.bzl) can reach -- test/,
examples/, and docs/ are not part of this module's exposed surface, and
neither are the embedded child workspaces under third_party/test/ (each has
its own WORKSPACE file, so Bazel walls it off from this module's package tree
the same way it would from a downstream consumer's).

Kept by hand because `glob()` cannot cross a package boundary, so there is no
way to derive this list from Starlark; `exposed_source_packages_test` below
fails loudly if a BUILD/BUILD.bazel file appears under any of the three roots
(outside an embedded child workspace) without being added here.
"""

load("@rules_shell//shell:sh_test.bzl", "sh_test")

EXPOSED_SOURCE_PACKAGES = [
    "scala",
    "scala/extensions",
    "scala/private",
    "scala/private/extensions",
    "scala/private/source_compat",
    "scala/private/toolchain_deps",
    "scala/scalafmt",
    "scala/scalafmt/toolchain",
    "scala/scalatest",
    "scala/settings",
    "scala/support",
    "scala/unstable",
    "src/java/io/bazel/rulesscala/coverage/instrumenter",
    "src/java/io/bazel/rulesscala/exe",
    "src/java/io/bazel/rulesscala/io_utils",
    "src/java/io/bazel/rulesscala/jar",
    "src/java/io/bazel/rulesscala/preconditions",
    "src/java/io/bazel/rulesscala/scala_test",
    "src/java/io/bazel/rulesscala/scalac",
    "src/java/io/bazel/rulesscala/scalac/compileoptions",
    "src/java/io/bazel/rulesscala/scalac/deps_tracking_reporter",
    "src/java/io/bazel/rulesscala/scalac/reporter",
    "src/java/io/bazel/rulesscala/specs2",
    "src/java/io/bazel/rulesscala/test_discovery",
    "src/java/io/bazel/rulesscala/worker",
    "src/protobuf/io/bazel/rules_scala",
    "src/scala/io/bazel/rules_scala/jmh_support",
    "src/scala/io/bazel/rules_scala/scaladoc_support",
    "src/scala/io/bazel/rules_scala/scrooge_support",
    "src/scala/scripts",
    "third_party/dependency_analyzer/src/main",
    "third_party/dependency_analyzer/src/main/io/bazel/rulesscala/dependencyanalyzer/compiler",
    "third_party/dependency_analyzer/src/test",
    "third_party/repositories",
    "third_party/utils/src/test",
]

def exposed_source_packages_test(name, **kwargs):
    """Fails if scala/, src/, or third_party/ gained/lost a BUILD-file package
    that EXPOSED_SOURCE_PACKAGES above doesn't (yet) reflect.

    Needs the real checkout, not just this test's runfiles, so it can `find`
    every BUILD file under the three roots -- same reason
    test/expect_build_failure's nested tests are tagged this way.
    """
    sh_test(
        name = name,
        srcs = ["exposed_source_packages_test.sh"],
        args = EXPOSED_SOURCE_PACKAGES,
        data = ["//test/expect_build_failure:nested_bazel.sh"],
        target_compatible_with = ["@platforms//os:linux"],
        tags = ["no-sandbox", "external"],
        **kwargs
    )
