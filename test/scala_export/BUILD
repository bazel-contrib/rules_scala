load("@aspect_bazel_lib//lib:diff_test.bzl", "diff_test")
load("@rules_scala//scala:scala.bzl", "scala_export", "scala_library")
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
        ":external_dep",
    ],
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

diff_test(
    name = "validate-pom",
    file1 = ":test-pom",
    file2 = "pom.golden.xml",
)

genrule(
    name = "list-scaladocs",
    srcs = [
        ":test-scaladocs",
    ],
    outs = ["scaladocs.txt"],
    cmd = "for SRC in $(SRCS); do jar tf $$SRC >> $@; done",
)

diff_test(
    name = "validate-scaladocs",
    file1 = ":scaladocs.txt",
    file2 = "scaladocs.golden.txt",
)
