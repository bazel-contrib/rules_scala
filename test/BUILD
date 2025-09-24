load("@rules_java//java:defs.bzl", "java_binary", "java_library")
load("@rules_scala_config//:config.bzl", "SCALA_VERSION")
load(
    "//scala:scala.bzl",
    "scala_binary",
    "scala_doc",
    "scala_junit_test",
    "scala_library",
    "scala_library_suite",
    "scala_macro_library",
    "scala_repl",
    "scala_specs2_junit_test",
    "scala_test",
    "scala_test_suite",
)
load("//scala:scala_cross_version.bzl", "repositories")
load(":check_statsfile.bzl", "check_statsfile")
load(":env_vars.bzl", "env_vars")

package(
    default_testonly = 1,
    default_visibility = ["//test/sh_tests:__pkg__"],
)

_JUNIT_DEPS = repositories(
    SCALA_VERSION,
    [
        "@io_bazel_rules_scala_junit_junit",
    ],
)

# The examples below show how to combine Scala and Java rules.
# ScalaBinary is the Scala equivalent of JavaBinary.

java_binary(
    name = "JavaBinary",
    srcs = ["JavaBinary.java"],
    main_class = "scalarules.test.JavaBinary",
    runtime_deps = [
        ":OtherJavaLib",
        "//scala/private/toolchain_deps:scala_library_classpath",
    ],
    deps = [
        ":Exported",
        ":HelloLib",
        ":OtherLib",
        ":Runtime",
    ],
)

java_binary(
    name = "JavaBinary2",
    srcs = ["JavaBinary.java"],
    main_class = "scalarules.test.JavaBinary",
    deps = [
        ":Exported",
        ":HelloLib",
        ":OtherLib",
        ":Runtime",
    ],
)

scala_binary(
    name = "ScalaBinary",
    srcs = ["ScalaBinary.scala"],
    main_class = "scalarules.test.ScalaBinary",
    print_compile_time = True,
    deps = [
        ":HelloLib",
        ":MacroTest",
    ],
)

scala_library(
    name = "HelloLib",
    srcs = ["HelloLib.scala"],
    deps = [
        "Exported",
        "MacroTest",
        "OtherJavaLib",
        "OtherLib",
    ],
)

scala_repl(
    name = "HelloLibRepl",
    deps = [":HelloLib"],
)

scala_test(
    name = "HelloLibTest",
    size = "small",  # Not a macro, can pass test-specific attributes.
    srcs = ["HelloLibTest.scala"],
    deps = [
        ":HelloLib",
    ],
)

# test that a library can depend on a test:
scala_library(
    name = "lib_to_test",
    srcs = ["LibToTest.scala"],
    deps = [":HelloLibTest"],
)

scala_test_suite(
    name = "HelloLibTestSuite",
    size = "small",  # Not a macro, can pass test-specific attributes.
    srcs = glob(["HelloLibTest*.scala"]),
    deps = [
        ":HelloLib",
    ],
)

scala_test_suite(
    name = "LongTestSuiteNamesSuite",
    size = "small",
    srcs = glob(["longnames/**/*.scala"]),
    use_short_names = True,
)

scala_test_suite(
    name = "TestSuitePassesKwArgs",
    size = "small",  # Not a macro, can pass test-specific attributes.
    srcs = ["ScalaTestData.scala"],
    data = ["//test/data:foo.txt"],
    jvm_flags = ["-Dtext=$(rootpath //test/data:foo.txt)"],
    scalac_jvm_flags = [
        "-Xms1G",
        "-Xmx4G",
    ],
)

scala_test(
    name = "TestFilterTests",
    size = "small",
    srcs = glob(["TestFilterTest*.scala"]),
)

scala_repl(
    name = "HelloLibTestRepl",
    deps = [":HelloLibTest"],
)

scala_library(
    name = "OtherLib",
    srcs = ["OtherLib.scala"],
    deps = ["ExportOnly"],
)

scala_doc(
    name = "ScalaDoc",
    deps = [
        ":HelloLib",
        ":OtherLib",
        "//test/src/main/scala/scalarules/test/compiler_plugin",  # brings kind-projector compiler plugin with it
    ],
)

scala_doc(
    name = "ScalaDocTestLibsOnly",
    deps = [
        ":HelloLib",
        ":OtherLib",
    ],
)

scala_library(
    name = "UnusedLib",
    srcs = ["UnusedLib.scala"],
)

scala_library(
    name = "UnusedDependencyChecker",
    srcs = ["OtherLib.scala"],
    unused_dependency_checker_mode = "error",
    deps = ["ExportOnly"],
)

scala_library(
    name = "UnusedDependencyCheckerWarn",
    srcs = ["OtherLib.scala"],
    unused_dependency_checker_mode = "warn",
    deps = [
        "ExportOnly",
        "UnusedLib",
    ],
)

# Test of library without src
scala_library(
    name = "ExportOnly",
    exports = ["Exported"],
)

scala_library(
    name = "Exported",
    srcs = ["Exported.scala"],
    runtime_deps = ["Runtime"],
)

# Test of a grouped library
scala_library_suite(
    name = "SuiteSrcs",
    srcs = glob(["Data*.scala"]),
)

scala_library_suite(
    name = "LibrarySuitePassesKwArgs",
    srcs = glob(["Data*.scala"]),
    scalac_jvm_flags = [
        "-Xms1G",
        "-Xmx4G",
    ],
)

scala_library(
    name = "ConsumeSuite",
    srcs = ["SuiteUsage.scala"],
    deps = ["SuiteSrcs"],
)

scala_macro_library(
    name = "MacroTest",
    srcs = ["MacroTest.scala"],
)

scala_library(
    name = "Runtime",
    srcs = ["Runtime.scala"],
)

java_library(
    name = "OtherJavaLib",
    srcs = ["OtherJavaLib.java"],
)

scala_library(
    name = "ScalaLibResources",
    srcs = ["src/main/scala/scalarules/test/ScalaLibResources.scala"],
    resources = [
        "//test/data:some.txt",
        "//test/src/main/resources/scalarules/test:byes",
        "//test/src/main/resources/scalarules/test:hellos",
    ],
)

scala_library(
    name = "ResourcesStripScalaLib",
    srcs = ["src/main/scala/scalarules/test/ResourcesStripScalaLib.scala"],
    resource_strip_prefix = "test/",
    resources = [
        "//test/data:foo.txt",
        "//test/data:more.txt",
        "//test/src/main/resources/scalarules/test:generated-hello",
        "//test/src/main/resources/scalarules/test:more-byes",
        "//test/src/main/resources/scalarules/test:more-hellos",
    ],
)

scala_binary(
    name = "ScalaLibBinary",
    srcs = ["src/main/scala/scalarules/test/ScalaLibBinary.scala"],
    main_class = "scalarules.test.ScalaLibBinary",
    deps = ["ScalaLibResources"],
)

scala_binary(
    name = "ResourcesStripScalaBinary",
    srcs = ["src/main/scala/scalarules/test/ResourcesStripScalaBinary.scala"],
    main_class = "scalarules.test.ResourcesStripScalaBinary",
    deps = ["ResourcesStripScalaLib"],
)

# test that a library can depend on a binary:
scala_library(
    name = "lib_to_bin",
    srcs = ["LibToBin.scala"],
    deps = [":ScalaLibBinary"],
)

scala_repl(
    name = "ScalaLibBinaryRepl",
    deps = [":ScalaLibBinary"],
)

scala_repl(
    name = "ResourcesStripScalaBinaryRepl",
    deps = [":ResourcesStripScalaBinary"],
)

scala_repl(
    name = "ReplWithSources",
    srcs = ["A.scala"],
)

scala_library(
    name = "jar_export",
    exports = ["@rules_scala_test_maven//:org_typelevel_cats_core_2_12"],
)

#Mix java scala
scala_library(
    name = "MixJavaScalaLib",
    srcs = glob(["src/main/scala/scalarules/test/mix_java_scala/*.scala"]) + glob([
        "src/main/scala/scalarules/test/mix_java_scala/*.java",
    ]),
)

scala_binary(
    name = "MixJavaScalaBinary",
    srcs = ["src/main/scala/scalarules/test/MixJavaScalaLibBinary.scala"] + glob([
        "src/main/scala/scalarules/test/mix_java_scala/*.scala",
    ]) + glob([
        "src/main/scala/scalarules/test/mix_java_scala/*.java",
    ]),
    main_class = "scalarules.test.JavaBinary",
)

scala_test(
    name = "MixJavaScalaScalaTest",
    size = "small",
    srcs = [
        "HelloLibTest.scala",
        "OtherJavaLib.java",
    ],
    deps = [
        ":HelloLib",
    ],
)

scala_junit_test(
    name = "MixJavaScalaJunitTest",
    size = "small",
    srcs = [
        "OtherJavaLib.java",
        "src/main/scala/scalarules/test/junit/HelloWorldJunitTest.scala",
    ],
    suffixes = ["Test"],
)

#needed to test java sources are compiled
scala_binary(
    name = "MixJavaScalaLibBinary",
    srcs = ["src/main/scala/scalarules/test/MixJavaScalaLibBinary.scala"],
    main_class = "scalarules.test.MixJavaScalaLibBinary",
    deps = ["MixJavaScalaLib"],
)

#Mix java scala (srcjar), much like above only the java is provided via srcjar
scala_library(
    name = "MixJavaScalaSrcjarLib",
    srcs = glob([
        "src/main/scala/scalarules/test/mix_java_scala/*.scala",
        # srcjar created with `jar -cfM Baz.srcjar Baz.java`
        "src/main/scala/scalarules/test/mix_java_scala/*.srcjar",
    ]),
)

#needed to test java sources are compiled
scala_binary(
    name = "MixJavaScalaSrcjarLibBinary",
    srcs = ["src/main/scala/scalarules/test/MixJavaScalaLibBinary.scala"],
    main_class = "scalarules.test.MixJavaScalaLibBinary",
    deps = ["MixJavaScalaSrcjarLib"],
)

scala_binary(
    name = "JavaOnlySources",
    srcs = ["src/main/scala/scalarules/test/only_java/Alpha.java"],
    main_class = "scalarules.test.Alpha",
)

scala_library(
    name = "JUnitCompileTimeDep",
    srcs = ["src/main/scala/scalarules/test/junit/support/JUnitCompileTimeDep.scala"],
)

scala_library(
    name = "JUnitRuntimeDep",
    srcs = ["src/main/scala/scalarules/test/junit/support/JUnitRuntimeDep.scala"],
)

scala_junit_test(
    name = "JunitTestWithDeps",
    size = "small",
    srcs = ["src/main/scala/scalarules/test/junit/JunitTests.scala"],
    jvm_flags = ["-XX:HeapDumpPath=/some/custom/path"],
    suffixes = ["Test"],
    runtime_deps = [":JUnitRuntimeDep"],
    deps = [":JUnitCompileTimeDep"],
)

scala_junit_test(
    name = "JunitMultipleSuffixes",
    size = "small",
    srcs = ["src/main/scala/scalarules/test/junit/JunitMultipleSuffixes.scala"],
    print_discovered_classes = True,
    suffixes = [
        "E2E",
        "IT",
    ],
)

scala_junit_test(
    name = "JunitMultiplePrefixes",
    size = "small",
    srcs = ["src/main/scala/scalarules/test/junit/JunitMultiplePrefixes.scala"],
    prefixes = [
        "Test",
        "OtherCustomPrefix",
    ],
    print_discovered_classes = True,
)

scala_junit_test(
    name = "JunitPrefixesAndSuffixes",
    size = "small",
    srcs = [
        "src/main/scala/scalarules/test/junit/JunitMultiplePrefixes.scala",
        "src/main/scala/scalarules/test/junit/JunitMultipleSuffixes.scala",
    ],
    prefixes = ["Test"],
    print_discovered_classes = True,
    suffixes = ["E2E"],
)

scala_junit_test(
    name = "JunitJavaTest",
    size = "small",
    srcs = ["src/main/scala/scalarules/test/junit/JunitJavaTest.java"],
    suffixes = ["Test"],
)

scala_specs2_junit_test(
    name = "Specs2Tests",
    size = "small",
    srcs = ["src/main/scala/scalarules/test/junit/specs2/Specs2Tests.scala"],
    print_discovered_classes = True,
    suffixes = ["Test"],
    deps = [":JUnitCompileTimeDep"],
)

scala_specs2_junit_test(
    name = "Specs2Tests_unused_dependency_checker",
    size = "small",
    srcs = ["src/main/scala/scalarules/test/junit/specs2/Specs2Tests.scala"],
    suffixes = ["Test"],
    unused_dependency_checker_ignored_targets = [":JUnitRuntimeDep"],
    unused_dependency_checker_mode = "error",
    deps = [
        ":JUnitCompileTimeDep",
        ":JUnitRuntimeDep",
    ],
)

# Make sure scala_binary respects runtime_jdk on bazel run
scala_binary(
    name = "scala_binary_jdk_11",
    srcs = ["ScalaBinaryJdk11.scala"],
    main_class = "scalarules.test.ScalaBinaryJdk11",
    runtime_jdk = "@rules_java//toolchains:remote_jdk11",
)

# Make sure scala_library respects java_compile_toolchain during builds
scala_junit_test(
    name = "CheckBytecodeMajorVersion",
    srcs = ["CheckBytecodeMajorVersionTest.scala"],
    suffixes = ["Test"],
    runtime_deps = [
        "//test/src/main/resources/java_sources:CompiledWithJava11",
        "//test/src/main/resources/java_sources:CompiledWithJava8",
    ],
)

scala_specs2_junit_test(
    name = "data_location_expansion",
    size = "small",
    srcs = ["src/main/scala/scalarules/test/location_expansion/LocationExpansionTest.scala"],
    data = ["//src/java/io/bazel/rulesscala/worker"],
    jvm_flags = ["-Dlocation.expanded='$(rootpaths //src/java/io/bazel/rulesscala/worker)'"],
    suffixes = ["Test"],
)

scala_junit_test(
    name = "JunitFiltersAbstractClassesAndInterfaces",
    size = "small",
    srcs = ["src/main/scala/scalarules/test/junit/JunitAbstractClassAndInterface.scala"],
    print_discovered_classes = True,
    suffixes = ["Test"],
)

scala_junit_test(
    name = "JunitFiltersInnerClasses",
    size = "small",
    srcs = ["src/main/scala/scalarules/test/junit/JunitInnerClass.scala"],
    prefixes = ["Test"],
    print_discovered_classes = True,
)

scala_junit_test(
    name = "JunitFiltersClassesWithoutTests",
    size = "small",
    srcs = ["src/main/scala/scalarules/test/junit/JunitNoTests.scala"],
    print_discovered_classes = True,
    suffixes = ["Test"],
)

scala_junit_test(
    name = "JunitIncludesClassesWithTestsFromParent",
    size = "small",
    srcs = ["src/main/scala/scalarules/test/junit/JunitIncludesTestHierarchies.scala"],
    print_discovered_classes = True,
    suffixes = ["Test"],
)

scala_junit_test(
    name = "JunitCustomRunner",
    size = "small",
    srcs = ["src/main/scala/scalarules/test/junit/JunitCustomRunnerTest.scala"],
    suffixes = ["Test"],
    deps = [":customJunitRunner"],
)

scala_junit_test(
    name = "JunitIncludesClassesWithRunWith",
    size = "small",
    srcs = ["src/main/scala/scalarules/test/junit/JunitIncludesRunWith.scala"],
    print_discovered_classes = True,
    suffixes = ["Test"],
)

scala_junit_test(
    name = "JunitFilterTest",
    size = "small",
    srcs = ["src/main/scala/scalarules/test/junit/FilterTest.scala"],
    print_discovered_classes = True,
    suffixes = ["Test"],
)

scala_library(
    name = "filesWithUtf8",
    srcs = [
        "src/main/scala/scalarules/test/utf8/JavaClassWithUtf8.java",
        "src/main/scala/scalarules/test/utf8/ScalaClassWithUtf8.scala",
    ],
)

scala_library(
    name = "customJunitRunner",
    srcs = ["src/main/scala/scalarules/test/junit/JunitCustomRunner.java"],
    deps = _JUNIT_DEPS,
)

# make sure making a fat jar strips signatures
java_library(
    name = "fakejar",
    resources = [
        "//test/src/main/resources/META-INF:FAKE.DSA",
        "//test/src/main/resources/META-INF:FAKE.RSA",
    ],
    visibility = ["//visibility:public"],
)

scala_binary(
    name = "ScalaBinary_with_fake",
    srcs = ["ScalaBinary.scala"],
    main_class = "scalarules.test.ScalaBinary",
    unused_dependency_checker_mode = "off",
    deps = [
        ":HelloLib",
        ":MacroTest",
        ":fakejar",
    ],
)

scala_binary(
    name = "ScalaBinary_with_service_manifest_srcs",
    srcs = ["A.scala"],
    main_class = "scalarules.test.A",
    unused_dependency_checker_mode = "off",
    deps = [
        "//test/example_jars:example_jar1",
        "//test/example_jars:example_jar2",
    ],
)

scala_binary(
    name = "ScalaBinary_dependent_on_binary_with_java",
    srcs = ["src/main/scala/scalarules/test/BinaryDependentOnJava.scala"],
    main_class = "scalarules.test.BinaryDependentOnJava",
    deps = [":JavaOnlySources"],
)

scala_library(
    name = "lib_with_scala_proto_dep",
    srcs = ["TestServer.scala"],
    deps = ["//test/proto:test_proto"],
)

scala_binary(
    name = "test_scala_proto_server",
    main_class = "test.proto.TestServer",
    deps = [":lib_with_scala_proto_dep"],
)

scala_library(
    name = "java_uses_scala_std_lib",
    srcs = ["JavaUsesScalaStdLib.java"],
)

check_statsfile("ScalaBinary")

check_statsfile("ScalaLibBinary")

#discovering tests from a separate target
scala_library(
    name = "JunitSeparateTarget",
    srcs = ["src/main/scala/scalarules/test/junit/separate_target/JunitSeparateTargetTest.scala"],
    deps = _JUNIT_DEPS,
)

scala_junit_test(
    name = "JunitSeparateTarget_test_runner",
    size = "small",
    suffixes = ["Test"],
    tests_from = [":JunitSeparateTarget"],
    runtime_deps = [":JunitSeparateTarget"],
)

java_library(
    name = "JunitJavaSeparateTarget",
    srcs = ["src/main/scala/scalarules/test/junit/separate_target/JunitJavaSeparateTargetTest.java"],
    deps = _JUNIT_DEPS,
)

scala_junit_test(
    name = "JunitJavaSeparateTarget_test_runner",
    size = "small",
    suffixes = ["Test"],
    tests_from = [":JunitJavaSeparateTarget"],
    runtime_deps = [":JunitJavaSeparateTarget"],
)

scala_library(
    name = "TargetWithTestThatShouldNotRun",
    srcs = ["src/main/scala/scalarules/test/junit/separate_target/FailingTest.scala"],
    deps = _JUNIT_DEPS,
)

scala_library(
    name = "JunitSeparateTargetWithDependencyOnTest",
    srcs = ["src/main/scala/scalarules/test/junit/separate_target/JunitSeparateTargetTest.scala"],
    runtime_deps = [":TargetWithTestThatShouldNotRun"],
    deps = _JUNIT_DEPS,
)

scala_junit_test(
    name = "JunitSeparateTargetTransitiveDependencyShouldNotRun_test_runner",
    size = "small",
    suffixes = ["Test"],
    tests_from = [":JunitSeparateTargetWithDependencyOnTest"],
    runtime_deps = [":JunitSeparateTargetWithDependencyOnTest"],
)

java_library(
    name = "JunitSeparateJavaTargetWithDependencyOnTest",
    srcs = ["src/main/scala/scalarules/test/junit/separate_target/JunitJavaSeparateTargetTest.java"],
    runtime_deps = [":TargetWithTestThatShouldNotRun"],
    deps = _JUNIT_DEPS,
)

scala_junit_test(
    name = "JunitSeparateJavaTargetTransitiveDependencyShouldNotRun_test_runner",
    size = "small",
    suffixes = ["Test"],
    tests_from = [":JunitSeparateJavaTargetWithDependencyOnTest"],
    runtime_deps = [":JunitSeparateJavaTargetWithDependencyOnTest"],
)

scala_library(
    name = "JunitMixedSeparateTarget",
    srcs = [
        "src/main/scala/scalarules/test/junit/separate_target/JunitJavaSeparateTargetTest.java",
        "src/main/scala/scalarules/test/junit/separate_target/SomeScalaClass.scala",
    ],
    deps = _JUNIT_DEPS,
)

scala_junit_test(
    name = "JunitMixedSeparateTarget_test_runner",
    size = "small",
    suffixes = ["Test"],
    tests_from = [":JunitMixedSeparateTarget"],
    runtime_deps = [":JunitMixedSeparateTarget"],
)

scala_library(
    name = "JunitRuntimePlatform",
    srcs = [
        "src/main/scala/scalarules/test/junit/runtime_platform/JunitRuntimePlatformTest.java",
    ],
    # make sure java compilation toolchain matches runtime toolchain ie --target
    java_compile_toolchain = "@rules_java//toolchains:toolchain_java11",
    deps = _JUNIT_DEPS,
)

scala_junit_test(
    name = "JunitRuntimePlatform_test_runner",
    size = "small",
    runtime_jdk = "@rules_java//toolchains:remote_jdk11",
    suffixes = ["Test"],
    tests_from = [":JunitRuntimePlatform"],
    runtime_deps = [":JunitRuntimePlatform"],
)

scala_junit_test(
    name = "JunitNoTestEnvironmentTest",
    size = "small",
    srcs = ["src/main/scala/scalarules/test/junit/JunitNoTestEnvironmentTest.scala"],
    suffixes = ["Test"],
)

scala_junit_test(
    name = "JunitSetTestEnvironmentTest",
    size = "small",
    srcs = ["src/main/scala/scalarules/test/junit/JunitSetTestEnvironmentTest.scala"],
    env = {
        "my_env_var": "my_value",
    },
    suffixes = ["Test"],
)

# Targets with inlining support

# If this target doesn't have build_ijar disabled, then InlinedExported will fail to compile.
scala_library(
    name = "InlinableExported",
    srcs = ["Exported.scala"],
    build_ijar = False,
    runtime_deps = ["Runtime"],
)

scala_library(
    name = "InlinedExported",
    srcs = ["OtherLib.scala"],
    scalacopts = [
        "-opt:l:inline",
        "-opt-inline-from:scalarules.test.**",
        # We need fatal warnings to ensure that the inlining actually worked.
        "-Xfatal-warnings",
    ],
    deps = [":InlinableExported"],
)

TEST_ENV = {
    "LOCATION": "West of House",
    "DEP_PATH": "$(rootpath :HelloLib)",
    "DATA_PATH": "$(rootpath //test/data:foo.txt)",
    "BINDIR": "$(BINDIR)",
    "FROM_TOOLCHAIN_VAR": "$(FOOBAR)",
    "ESCAPED": "$$(rootpath //test/data:foo.txt) $$(BINDIR) $$UNKNOWN",
}

scala_binary(
    name = "EnvAttributeBinary",
    srcs = ["EnvAttributeBinary.scala"],
    main_class = "scalarules.test.EnvAttributeBinary",
    data = ["//test/data:foo.txt"],
    deps = [":HelloLib"],
    env = TEST_ENV | {"SRC_PATH": "$(rootpath EnvAttributeBinary.scala)"},
    toolchains = [":test_vars"],
    unused_dependency_checker_mode = "off",
    testonly = True,
)

scala_test(
    name = "EnvAttributeTest",
    size = "small",
    srcs = ["EnvAttributeTest.scala"],
    data = ["//test/data:foo.txt"],
    deps = [":HelloLib"],
    env = TEST_ENV | {"SRC_PATH": "$(rootpath EnvAttributeTest.scala)"},
    toolchains = [":test_vars"],
    unused_dependency_checker_mode = "off",
)

scala_junit_test(
    name = "EnvAttributeJunitTest",
    size = "small",
    srcs = ["src/main/scala/scalarules/test/junit/EnvAttributeJunitTest.scala"],
    suffixes = ["Test"],
    data = ["//test/data:foo.txt"],
    deps = [":HelloLib"],
    env = TEST_ENV | {
        "SRC_PATH": (
            "$(rootpath " +
            "src/main/scala/scalarules/test/junit/EnvAttributeJunitTest.scala)"
        ),
    },
    toolchains = [":test_vars"],
    unused_dependency_checker_mode = "off",
)

env_vars(
    name = "test_vars",
    vars = {"FOOBAR": "bazquux"},
)

# Used by test_scala_test_env_attribute_with_env_inherit_and_test_env
# from test/shell/test_env_attribute_expansion.sh.
scala_test(
    name = "EnvAttributeManualTest",
    size = "small",
    srcs = ["EnvAttributeManualTest.scala"],
    env = {
        "FROM_TEST_ENV_AND_ENV_ATTR": "env attribute value",
        "FROM_ENV_INHERIT_AND_ENV_ATTR": "env attribute value",
        "FROM_ALL_SOURCES": "env attribute value",
    },
    env_inherit = [
        "FROM_ENV_INHERIT",
        "FROM_ENV_INHERIT_AND_ENV_ATTR",
        "FROM_ENV_INHERIT_AND_TEST_ENV",
        "FROM_ALL_SOURCES",
    ],
    tags = ["manual"],
)
