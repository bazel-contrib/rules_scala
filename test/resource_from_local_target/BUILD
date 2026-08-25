load("@rules_python//python:defs.bzl", "py_binary")
load("//scala:scala.bzl", "scala_test")

package(default_testonly = 1)

py_binary(
    name = "py_resource_binary",
    srcs = ["py_resource.py"],
    main = "py_resource.py",
)

scala_test(
    name = "ScalaTestResourcesFromLocalTargetTest",
    srcs = ["ScalaTestResourcesFromLocalTargetTest.scala"],
    resources = [":py_resource_binary"],
)
