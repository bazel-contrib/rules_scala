load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//scala:scala.bzl", "scala_doc", "scala_library")
load("//scala:scala_import.bzl", "scala_import")
load("//test/expect_build_failure:expect_analysis_failure.bzl", "expect_analysis_failure_test")
load("//test/expect_build_failure:toolchain_transition.bzl", "toolchain_build_test")
load("scaladoc.bzl", "scala_doc_intransitive", "scala_doc_old_fields", "expect_analysis_failure_without_doc_classpath_test")

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
    tags = ["local", "no-release", "requires-network"],
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
    tags = ["local", "no-release", "requires-network"],
)

# Test that scaladoc for transitive external deps works (just build succeeds).
toolchain_build_test(
    name = "scaladoc_C_build_test",
    extra_toolchains = ["//test/toolchains:ast_plus_one_deps_unused_deps_warn"],
    target = ":scaladoc_C",
)

scala_library(
    name = "Scala3Enum",
    srcs = ["Color.scala"],
    scala_version = "3.7.4",
)

scala_library(
    name = "Sibling",
    srcs = ["Sibling.scala"],
)

scala_library(
    name = "Scala2Lib",
    srcs = ["Sibling.scala"],
    scala_version = "2.13.18",
)

scala_library(
    name = "Siblings",
    srcs = ["Siblings.scala"],
    deps = [
        ":A",
        ":Sibling",
    ],
)

scala_doc(
    name = "scaladoc_siblings",
    deps = [":Siblings"],
)

scala_doc_old_fields(
    name = "scaladoc_old_fields",
    scala_version = "2.13.18",
    deps = [":Sibling"],
)

build_test(
    name = "scaladoc_old_fields_build_test",
    targets = [":scaladoc_old_fields"],
)

scala_doc_old_fields(
    name = "scaladoc_old_fields_scala3",
    scala_version = "3.7.4",
    tags = ["manual"],
    deps = [":Scala3Enum"],
)

expect_analysis_failure_test(
    name = "scaladoc_old_fields_scala3_test",
    message = "Scala 3 `scala_doc` needs `class_jars` in `ScaladocAspectInfo`",
    target_under_test = ":scaladoc_old_fields_scala3",
)

scala_library(
    name = "Scala3Shape",
    srcs = ["Shape.scala"],
    scala_version = "3.7.4",
)

scala_library(
    name = "Scala3Drawing",
    srcs = ["Drawing.scala"],
    scala_version = "3.7.4",
    deps = [
        ":Scala3Enum",
        ":Scala3Shape",
    ],
)

# Scala 3.3.1 is the oldest Scala 3 version that runs on JDK 21, which CI
# also uses.
_OTHER_SCALA3_VERSIONS = [
    "3.3.9",
    "3.10.0",
]

[
    scala_library(
        name = "Scala3Enum_" + version.replace(".", "_"),
        srcs = ["Color.scala"],
        scala_version = version,
    )
    for version in _OTHER_SCALA3_VERSIONS
]

[
    scala_doc(
        name = "scaladoc_scala3_" + version.replace(".", "_"),
        scala_version = version,
        deps = [":Scala3Enum_" + version.replace(".", "_")],
    )
    for version in _OTHER_SCALA3_VERSIONS
]

[
    genrule(
        name = name + "_pages",
        srcs = [":" + name],
        outs = [name + "_pages.txt"],
        cmd = "(cd $< && find -L . -type f -name '*.html') | LC_ALL=C sort > $@",
    )
    for name in [
        "scaladoc_siblings",
        "scaladoc_scala3_transitive",
        "scaladoc_scala3_intransitive",
    ] + ["scaladoc_scala3_" + v.replace(".", "_") for v in _OTHER_SCALA3_VERSIONS]
]

scala_doc(
    name = "scaladoc_scala3_transitive",
    scala_version = "3.7.4",
    scalacopts = [
        "-project-footer",
        "It's C:\\temp \"x\"",
    ],
    deps = [":Scala3Drawing"],
)

scala_doc_intransitive(
    name = "scaladoc_scala3_intransitive",
    scala_version = "3.7.4",
    deps = [":Scala3Drawing"],
)

[
    sh_test(
        name = "%s_%s_%s" % (target, "has" if expect == "true" else "omits", page.split("/")[-1].removesuffix(".html").removesuffix("$")),
        srcs = ["//test/string_checks:string_in_file.sh"],
        args = [
            expect,
            "'%s'" % page.replace("$", "$$"),
            "$(rootpath :%s_pages)" % target,
        ],
        data = [":%s_pages" % target],
    )
    for target, expect, page in [
        ("scaladoc_siblings", "true", "./A$.html"),
        ("scaladoc_siblings", "true", "./Sibling$.html"),
        ("scaladoc_scala3_transitive", "true", "./scalarules/test/scaladoc/Drawing.html"),
        ("scaladoc_scala3_transitive", "true", "./scalarules/test/scaladoc/Color.html"),
        ("scaladoc_scala3_transitive", "true", "./scalarules/test/scaladoc/Shape.html"),
        ("scaladoc_scala3_intransitive", "true", "./scalarules/test/scaladoc/Drawing.html"),
        ("scaladoc_scala3_intransitive", "false", "./scalarules/test/scaladoc/Color.html"),
        ("scaladoc_scala3_intransitive", "false", "./scalarules/test/scaladoc/Shape.html"),
    ] + [
        ("scaladoc_scala3_" + v.replace(".", "_"), "true", "./scalarules/test/scaladoc/Color.html")
        for v in _OTHER_SCALA3_VERSIONS
    ]
]

genrule(
    name = "scaladoc_scala3_pages",
    srcs = [":scaladoc_scala3_transitive"],
    outs = ["scaladoc_scala3_pages.html"],
    cmd = "cat $</index.html $</scalarules/test/scaladoc/Color.html > $@",
)

sh_test(
    name = "scaladoc_scala3_has_doc_comment",
    srcs = ["//test/string_checks:string_in_file.sh"],
    args = [
        "true",
        "'The red color'",
        "$(rootpath :scaladoc_scala3_pages)",
    ],
    data = [":scaladoc_scala3_pages"],
)

sh_test(
    name = "scaladoc_scala3_has_footer",
    srcs = ["//test/string_checks:string_in_file.sh"],
    args = [
        "true",
        "'It&apos;s C:\\temp &quot;x&quot;'",
        "$(rootpath :scaladoc_scala3_pages)",
    ],
    data = [":scaladoc_scala3_pages"],
)

scala_doc(
    name = "scaladoc_version_mismatch",
    scala_version = "2.13.18",
    tags = ["manual"],
    deps = [":Scala3Enum"],
)

scala_doc(
    name = "scaladoc_scala3_over_scala2",
    scala_version = "3.7.4",
    tags = ["manual"],
    deps = [":Scala2Lib"],
)

expect_analysis_failure_test(
    name = "scaladoc_scala3_over_scala2_test",
    message = "a dependency uses Scala 2.13.18, and this target uses Scala 3.7.4",
    target_under_test = ":scaladoc_scala3_over_scala2",
)

expect_analysis_failure_test(
    name = "scaladoc_version_mismatch_test",
    message = "a dependency uses Scala 3.7.4, and this target uses Scala 2.13.18",
    target_under_test = ":scaladoc_version_mismatch",
)

expect_analysis_failure_without_doc_classpath_test(
    name = "scaladoc_without_doc_classpath_test",
    message = "Scala 3 `scala_doc` needs `scala_doc_classpath` on the Scala toolchain.",
    tags = ["skip-toolchain-sweep"],
    target_under_test = ":scaladoc_scala3_transitive",
)
