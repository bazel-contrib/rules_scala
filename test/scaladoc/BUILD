load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//scala:scala.bzl", "scala_doc", "scala_library")
load("//scala:scala_import.bzl", "scala_import")
load("//test/expect_build_failure:expect_analysis_failure.bzl", "expect_analysis_failure_test")
load("//test/expect_build_failure:toolchain_transition.bzl", "build_under_toolchains", "toolchain_build_test")
load("scaladoc.bzl", "expect_analysis_failure_with_scaladoc_version_mismatch_test", "expect_analysis_failure_without_doc_classpath_test", "scala_doc_intransitive", "scala_doc_old_fields", "site_dir")

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
    scala_version = "3.9.0",
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
    scala_version = "3.9.0",
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
    scala_version = "3.9.0",
)

scala_library(
    name = "Scala3Drawing",
    srcs = ["Drawing.scala"],
    scala_version = "3.9.0",
    deps = [
        ":Scala3Enum",
        ":Scala3Shape",
    ],
)

# The older LTS line and the newest Scala 3 version.
_OTHER_SCALA3_VERSIONS = [
    "3.3.9",
    "3.10.1",
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

genrule(
    name = "generated_page",
    outs = ["site/_docs/generated.md"],
    cmd = "printf -- '---\\ntitle: Generated\\n---\\n' > $@",
)

site_dir(name = "tree_site")

scala_doc(
    name = "scaladoc_tree_site",
    scala_version = "3.9.0",
    site_root = "tree_site",
    site_srcs = [":tree_site"],
    deps = [":Scala3Enum"],
)

[
    scala_doc(
        name = "scaladoc_site_" + version.replace(".", "_"),
        scala_version = version,
        site_root = "site",
        site_srcs = glob(["site/**"]) + [":generated_page"],
        deps = [":Scala3Enum" + ("" if version == "3.9.0" else "_" + version.replace(".", "_"))],
    )
    for version in ["3.9.0"] + _OTHER_SCALA3_VERSIONS
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
        "scaladoc_scala3_over_scala2",
    ] + ["scaladoc_scala3_" + v.replace(".", "_") for v in _OTHER_SCALA3_VERSIONS] + [
        "scaladoc_site_" + v.replace(".", "_")
        for v in ["3.9.0"] + _OTHER_SCALA3_VERSIONS
    ] + ["scaladoc_tree_site"]
]

scala_doc(
    name = "scaladoc_scala3_transitive",
    scala_version = "3.9.0",
    scalacopts = [
        "-project-footer",
        "It's C:\\temp \"x\"",
    ],
    deps = [":Scala3Drawing"],
)

scala_doc_intransitive(
    name = "scaladoc_scala3_intransitive",
    scala_version = "3.9.0",
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
        # Scaladoc puts the empty package in `$lessempty$greater$`, and on
        # Windows the test arg loses `$lessempty$greater`. Match the page only.
        ("scaladoc_scala3_over_scala2", "true", "/UsesSibling$.html"),
    ] + [
        ("scaladoc_scala3_" + v.replace(".", "_"), "true", "./scalarules/test/scaladoc/Color.html")
        for v in _OTHER_SCALA3_VERSIONS
    ] + [
        ("scaladoc_site_" + v.replace(".", "_"), "true", page)
        for v in ["3.9.0"] + _OTHER_SCALA3_VERSIONS
        for page in [
            "./docs/guide.html",
            "./docs/generated.html",
        ]
    ] + [("scaladoc_tree_site", "true", "./docs/tree.html")]
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
        "'scaladoc_scala3_has_doc_comment looks for this text in the scala_doc output.'",
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

# With transitive deps on the compile classpath, as in a toolchain sweep of
# test_rules_scala.sh, Scala 3 code that uses Scala 2 code gets two
# scala-library versions. Thus build it with the registered toolchains only.
scala_library(
    name = "UsesScala2",
    srcs = ["UsesSibling.scala"],
    scala_version = "3.9.0",
    tags = ["manual"],
    deps = [":Scala2Lib"],
)

scala_doc(
    name = "scaladoc_scala3_over_scala2_doc",
    scala_version = "3.9.0",
    tags = ["manual"],
    deps = [":UsesScala2"],
)

build_under_toolchains(
    name = "scaladoc_scala3_over_scala2",
    extra_toolchains = [],
    target = ":scaladoc_scala3_over_scala2_doc",
)

expect_analysis_failure_test(
    name = "scaladoc_version_mismatch_test",
    message = "a dependency uses Scala 3.9.0, and this target uses Scala 2.13.18",
    target_under_test = ":scaladoc_version_mismatch",
)

expect_analysis_failure_with_scaladoc_version_mismatch_test(
    name = "scaladoc_version_mismatch_with_compiler_test",
    message = "Scaladoc 3.3.9 runs only with Scala compiler 3.3.9, and the Scala toolchain gives compiler 3.9.0.",
    tags = ["skip-toolchain-sweep"],
    target_under_test = ":scaladoc_scala3_transitive",
)

expect_analysis_failure_without_doc_classpath_test(
    name = "scaladoc_without_doc_classpath_test",
    message = "Scala 3 `scala_doc` needs `scala_doc_classpath` on the Scala toolchain.",
    tags = ["skip-toolchain-sweep"],
    target_under_test = ":scaladoc_scala3_transitive",
)

scala_doc(
    name = "scaladoc_scala3_line_break",
    scala_version = "3.9.0",
    scalacopts = [
        "-project-footer",
        "first\nsecond",
    ],
    tags = ["manual"],
    deps = [":Scala3Shape"],
)

expect_analysis_failure_test(
    name = "scaladoc_scala3_line_break_test",
    message = "each `scalacopts` value of Scala 3 `scala_doc` must be one line",
    target_under_test = ":scaladoc_scala3_line_break",
)

# Scala 2 `scala_doc` runs without `scala_doc_classpath`.
toolchain_build_test(
    name = "scaladoc_scala2_without_doc_classpath_test",
    extra_toolchains = ["//test/toolchains/scala_doc_classpath_missing:toolchain_scala2"],
    target = ":scaladoc_old_fields",
)

scala_doc(
    name = "scaladoc_scala2_site",
    scala_version = "2.13.18",
    site_srcs = ["site/_docs/guide.md"],
    tags = ["manual"],
    deps = [":Sibling"],
)

expect_analysis_failure_test(
    name = "scaladoc_scala2_site_test",
    message = "`site_srcs` works only with Scala 3. This target uses Scala 2.13.18.",
    target_under_test = ":scaladoc_scala2_site",
)

scala_doc(
    name = "scaladoc_site_outside_root",
    scala_version = "3.9.0",
    site_root = "site/_docs",
    site_srcs = ["A.scala"],
    tags = ["manual"],
    deps = [":Scala3Enum"],
)

expect_analysis_failure_test(
    name = "scaladoc_site_outside_root_test",
    message = "`site_srcs` file test/scaladoc/A.scala is not under `site_root` test/scaladoc/site/_docs.",
    target_under_test = ":scaladoc_site_outside_root",
)

scala_doc(
    name = "scaladoc_scala3_siteroot_opt",
    scala_version = "3.9.0",
    scalacopts = [
        "-siteroot",
        "docs",
    ],
    tags = ["manual"],
    deps = [":Scala3Shape"],
)

expect_analysis_failure_test(
    name = "scaladoc_scala3_siteroot_opt_test",
    message = "Scala 3 `scala_doc` sets `-siteroot`. Use `site_srcs` and `site_root` for static site files.",
    target_under_test = ":scaladoc_scala3_siteroot_opt",
)
