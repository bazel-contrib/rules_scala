load(
    "@rules_scala_config//:config.bzl",
    "SCALA_MAJOR_VERSION",
    "SCALA_VERSION",
)
load("//scala:scala.bzl", "scala_test")
load("//scala:scala_cross_version.bzl", "version_suffix")
load("//scala:scala_cross_version_select.bzl", "select_for_scala_version")

def tests():
    suffix = version_suffix(SCALA_VERSION)
    scala_2_library_label = "@rules_scala_compiler{}//:org_scala_lang_scala_library".format(suffix)
    scala_3_library_label = "@rules_scala_compiler{}//:org_scala_lang_scala3_library_3".format(suffix)
    scala_reflect_label = "@rules_scala_compiler{}//:org_scala_lang_scala_reflect".format(suffix)
    common_jvm_flags = [
        "-Dplugin.jar.location=$(execpath //third_party/dependency_analyzer/src/main:dependency_analyzer)",
    ] + select_for_scala_version(
        any_2 = [
            "-Dscala.library.location=$(rootpath {})".format(scala_2_library_label),
            "-Dscala.reflect.location=$(rootpath {})".format(scala_reflect_label),
        ],
        any_3 = [
            "-Dscala.library.location=$(rootpath {})".format(scala_3_library_label),
            "-Dscala.library2.location=$(rootpath {})".format(scala_2_library_label),
        ],
    )

    scala_std_dependencies = [scala_2_library_label] + select_for_scala_version(
        any_2 = [scala_reflect_label],
        any_3 = [scala_3_library_label],
    )

    scala_compiler_dependencies = select_for_scala_version(
        any_2 = ["@rules_scala_compiler{}//:org_scala_lang_scala_compiler".format(suffix)],
        any_3 = ["@rules_scala_compiler{}//:org_scala_lang_scala3_compiler_3".format(suffix)],
    )

    scala_test(
        name = "ast_used_jar_finder_test",
        size = "small",
        srcs = [
            "io/bazel/rulesscala/dependencyanalyzer/AstUsedJarFinderTest.scala",
        ],
        jvm_flags = common_jvm_flags,
        deps = scala_std_dependencies + [
            "//src/java/io/bazel/rulesscala/io_utils",
            "//third_party/dependency_analyzer/src/main:dependency_analyzer",
            "//third_party/dependency_analyzer/src/main:scala_version",
            "//third_party/utils/src/test:test_util",
        ],
    )

    scala_test(
        name = "scalac_dependency_test",
        size = "small",
        srcs = [
            "io/bazel/rulesscala/dependencyanalyzer/ScalacDependencyTest.scala",
        ],
        jvm_flags = common_jvm_flags,
        unused_dependency_checker_mode = "off",
        deps = scala_compiler_dependencies + scala_std_dependencies + [
            "//src/java/io/bazel/rulesscala/io_utils",
            "//third_party/dependency_analyzer/src/main:dependency_analyzer",
            "//third_party/utils/src/test:test_util",
        ],
    )

    scala_test(
        name = "strict_deps_test",
        size = "small",
        srcs = [
            "io/bazel/rulesscala/dependencyanalyzer/StrictDepsTest.scala",
        ],
        jvm_flags = common_jvm_flags + [
            "-Dguava.jar.location=$(rootpath @rules_scala_test_maven//:com_google_guava_guava)",
            "-Dapache.commons.jar.location=$(rootpath @rules_scala_test_maven//:org_apache_commons_commons_lang3)",
        ],
        unused_dependency_checker_mode = "off",
        deps = scala_compiler_dependencies + scala_std_dependencies + [
            "//third_party/dependency_analyzer/src/main:dependency_analyzer",
            "//third_party/utils/src/test:test_util",
            "@rules_scala_test_maven//:com_google_guava_guava",
            "@rules_scala_test_maven//:org_apache_commons_commons_lang3",
        ],
    )

    scala_test(
        name = "unused_dependency_checker_test",
        size = "small",
        srcs = [
            "io/bazel/rulesscala/dependencyanalyzer/UnusedDependencyCheckerTest.scala",
        ],
        jvm_flags = common_jvm_flags + [
            "-Dapache.commons.jar.location=$(rootpath @rules_scala_test_maven//:org_apache_commons_commons_lang3)",
        ],
        unused_dependency_checker_mode = "off",
        deps = scala_compiler_dependencies + scala_std_dependencies + [
            "//third_party/dependency_analyzer/src/main:dependency_analyzer",
            "//third_party/utils/src/test:test_util",
            "@rules_scala_test_maven//:org_apache_commons_commons_lang3",
        ],
    )

    scala_test(
        name = "test_that_tests_run",
        size = "small",
        jvm_flags = common_jvm_flags,
        srcs = [
            "io/bazel/rulesscala/dependencyanalyzer/CompileTest.scala",
        ],
        unused_dependency_checker_mode = "off",
        deps = scala_std_dependencies + [
            "//third_party/dependency_analyzer/src/main:dependency_analyzer",
            "//third_party/utils/src/test:test_util",
        ],
    )

    scala_test(
        name = "scala_version_test",
        srcs = ["io/bazel/rulesscala/dependencyanalyzer/ScalaVersionTest.scala"],
        deps = ["//third_party/dependency_analyzer/src/main:scala_version"],
    )

def version_specific_tests():
    if SCALA_MAJOR_VERSION.startswith("2"):
        analyzer_tests_scala_2(SCALA_VERSION)

def analyzer_tests_scala_2(scala_version):
    suffix = version_suffix(scala_version)

    scala_test(
        name = "scala_version_macros_test",
        size = "small",
        srcs = [
            "io/bazel/rulesscala/dependencyanalyzer/ScalaVersionMacrosTest.scala",
        ],
        deps = [
            "//third_party/dependency_analyzer/src/main:scala_version",
            "@rules_scala_compiler{}//:org_scala_lang_scala_library".format(suffix),
            "@rules_scala_compiler{}//:org_scala_lang_scala_reflect".format(suffix),
        ],
    )
