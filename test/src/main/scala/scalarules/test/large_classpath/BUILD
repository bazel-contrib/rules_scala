load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//scala:scala.bzl", "scala_binary", "scala_library")
load(":helper.bzl", "create_dependencies", "get_dependency_labels")

scala_binary(
    name = "largeClasspath",
    srcs = ["ObjectWithLargeClasspath.scala"],
    main_class = "scalarules.test.large_classpath.ObjectWithLargeClasspath",
    unused_dependency_checker_mode = "off",
    visibility = ["//visibility:public"],
    deps = get_dependency_labels(
        amount = 1000,
        length = 20,
    ),
)

scala_library(
    name = "triggerDeployJarCreation",
    data = [":largeClasspath_deploy.jar"],
)

create_dependencies(
    amount = 1000,
    length = 20,
)

sh_test(
    name = "test_binary_run_with_large_classpath",
    srcs = ["test_binary_run_with_large_classpath.sh"],
    args = ["$(rootpath :largeClasspath)"],
    data = [":largeClasspath"],
)
