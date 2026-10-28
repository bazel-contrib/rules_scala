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

sh_test(
    name = "validate-pom",
    srcs = ["diff.sh"],
    args = [
        "$(rootpath :test-pom)",
        "$(rootpath pom.golden.xml)",
    ],
    data = [
        ":test-pom",
        "pom.golden.xml",
    ],
)

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
