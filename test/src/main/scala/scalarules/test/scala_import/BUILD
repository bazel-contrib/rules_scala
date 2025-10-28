load("@rules_java//java:defs.bzl", "java_import")
load("//scala:scala.bzl", "scala_library", "scala_specs2_junit_test")
load("//scala:scala_import.bzl", "scala_import")
load(":scala_import_stamp_test.bzl", "scala_import_stamping_test_suite")

#Many jars
scala_import(
    name = "guava_and_commons_lang",
    jars = [
        "@rules_scala_test_maven//:com_google_guava_guava",
        "@rules_scala_test_maven//:org_apache_commons_commons_lang3",
    ],
)

scala_import(
    name = "jffi_native_external",
    testonly = True,
    jars = [
        "@rules_scala_test_maven//:com_github_jnr_jffi",
    ],
)

scala_library(
    name = "generic_scalalib",
    testonly = True,
    srcs = ["generic/Generic.scala"],
    visibility = ["//visibility:private"],
)

scala_import(
    name = "imported_genericlib_jar",
    jars = [
        ":generic_scalalib.jar",
    ],
)

scala_specs2_junit_test(
    name = "scala_import_exposes_jars",
    size = "small",
    srcs = ["ScalaImportExposesJarsTest.scala"],
    suffixes = ["Test"],
    deps = [":guava_and_commons_lang"],
)

scala_specs2_junit_test(
    name = "scala_import_exposes_file_jars",
    size = "small",
    srcs = ["ScalaImportExposesFileJarsTest.scala"],
    suffixes = ["Test"],
    deps = [":imported_genericlib_jar"],
)

##Runtime deps
scala_import(
    name = "indirection_for_transitive_runtime_deps",
    testonly = True,
    jars = [],
    deps = ["@rules_scala_test_maven//:org_typelevel_cats_core_2_12"],
)

scala_import(
    name = "cats_and_guava_and_commons_lang_as_runtime_deps",
    testonly = True,
    jars = [],
    runtime_deps = [
        ":guava_and_commons_lang",
        ":indirection_for_transitive_runtime_deps",
    ],
)

scala_specs2_junit_test(
    name = "scala_import_propagates_runtime_deps",
    size = "small",
    srcs = ["ScalaImportPropagatesRuntimeDepsTest.scala"],
    suffixes = ["Test"],
    runtime_deps = [":cats_and_guava_and_commons_lang_as_runtime_deps"],
)

java_import(
    name = "guava_and_commons_lang_java_import",
    jars = [
        "@rules_scala_test_maven//:com/google/guava/guava/21.0/guava-21.0.jar",
        "@rules_scala_test_maven//:org/apache/commons/commons-lang3/3.18.0/commons-lang3-3.18.0.jar",
    ],
)

#Exports
scala_import(
    name = "guava_and_commons_lang_as_exports",
    exports = [":guava_and_commons_lang"],
)

# we're testing the scenario:
# jar <- java_import <- scala_import (exports) <- scala_specs2_junit_test
# see for details https://github.com/bazelbuild/rules_scala/issues/354
scala_import(
    name = "guava_and_commons_lang_as_exports_from_java_import",
    exports = [":guava_and_commons_lang_java_import"],
)

scala_specs2_junit_test(
    name = "scala_import_exports_targets",
    size = "small",
    srcs = ["ScalaImportExposesJarsTest.scala"],
    suffixes = ["Test"],
    deps = [":guava_and_commons_lang_as_exports"],
)

# same as above but deps are routed via java_import instead of
# scala_import
scala_specs2_junit_test(
    name = "scala_import_exports_java_import_targets",
    size = "small",
    srcs = ["ScalaImportExposesJarsTest.scala"],
    suffixes = ["Test"],
    deps = [":guava_and_commons_lang_as_exports"],
)

# test stamping of the same dep twice
# https://github.com/bazelbuild/rules_scala/issues/1188
scala_import(
    name = "stamping_first_time",
    jars = ["//test/src/main/scala/scalarules/test/scala_import/nl:libscala_import_never_link.jar"],
)

scala_import(
    name = "stamping_second_time",
    jars = ["//test/src/main/scala/scalarules/test/scala_import/nl:libscala_import_never_link.jar"],
)

scala_import_stamping_test_suite(
    name = "stamping_tests",
    jar = "//test/src/main/scala/scalarules/test/scala_import/nl:libscala_import_never_link.jar",
)
