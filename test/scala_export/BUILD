load("@rules_scala//scala:scala.bzl", "scala_library")
load("@rules_scala//scala:scala_export.bzl", "scala_export")
load("@rules_shell//shell:sh_test.bzl", "sh_test")

scala_library(
    name = "deploy_env_dep",
    srcs = ["DeployEnvDependency.scala"],
    deps = [],
)

scala_library(
    name = "dep",
    srcs = ["Dependency.scala"],
)

scala_export(
    name = "external_dep",
    srcs = ["ExternalDependency.scala"],
    maven_coordinates = "com.example:external:1.0.0",
)

scala_export(
    name = "test",
    srcs = [
        "Main.scala",
    ],
    deploy_env = [
        ":deploy_env_dep",
    ],
    maven_coordinates = "com.example:scala:1.0.0",
    unused_dependency_checker_mode = "off",
    deps = [
        ":dep",
        ":deploy_env_dep",
        ":external_dep",
    ],
)

scala_export(
    name = "testonly_export",
    testonly = True,
    srcs = ["Dependency.scala"],
    maven_coordinates = "com.example:testonly:1.0.0",
)

genrule(
    name = "list-classes",
    srcs = [
        ":test-project",
    ],
    outs = ["classes.txt"],
    cmd = "for SRC in $(SRCS); do jar tf $$SRC >> $@; done",
)

sh_test(
    name = "check-deploy-env",
    srcs = [
        "check-deploy-env.sh",
    ],
    data = [
        ":classes.txt",
    ],
    deps = [
        "@bazel_tools//tools/bash/runfiles",
    ],
)

scala_export(
    name = "scala3_export",
    srcs = ["Dependency.scala"],
    maven_coordinates = "com.example:scala3:1.0.0",
    scala_version = "3.7.4",
)

scala_export(
    name = "bundled_stdlib_export",
    srcs = ["ExternalDependency.scala"],
    maven_coordinates = "com.example:bundled:1.0.0",
    scala_library_maven_deps = None,
)

[
    genrule(
        name = "list-%s-classes" % target,
        srcs = [":%s-project" % target],
        outs = ["%s_classes.txt" % target],
        cmd = "jar tf $< > $@",
    )
    for target in [
        "external_dep",
        "bundled_stdlib_export",
    ]
]

# The Scala standard library goes in the pom with compile scope, and its classes
# stay out of the jar. The jar check uses `:external_dep`, because the `deploy_env` of `:test`
# also removes them.
[
    sh_test(
        name = name,
        srcs = ["//test/string_checks:string_in_file.sh"],
        args = [
            expected,
            string,
            "$(rootpath %s)" % file,
        ],
        data = [file],
    )
    for name, expected, string, file in [
        ("pom-has-external", "true", "external", ":test-pom"),
        ("pom-has-scala-library", "true", "scala-library", ":test-pom"),
        ("pom-has-scala3-library", "true", "scala3-library_3", ":scala3_export-pom"),
        ("pom-has-compile-scope", "false", "runtime", ":scala3_export-pom"),
        ("jar-has-no-scala-classes", "false", "scala/", ":external_dep_classes.txt"),
        ("bundled-jar-has-scala-classes", "true", "scala/", ":bundled_stdlib_export_classes.txt"),
    ]
]

genrule(
    name = "list-scaladocs",
    srcs = [
        ":test-javadoc",
    ],
    outs = ["scaladocs.txt"],
    cmd = "for SRC in $(SRCS); do jar tf $$SRC >> $@; done",
)

sh_test(
    name = "validate-scaladocs",
    srcs = ["diff.sh"],
    args = [
        "$(rootpath :scaladocs.txt)",
        "$(rootpath scaladocs.golden.txt)",
    ],
    data = [
        ":scaladocs.txt",
        "scaladocs.golden.txt",
    ],
)
