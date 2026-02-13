"""
A simple hello world library in Scala Native built with Bazel.
"""
load(
    "@rules_scala//scala:scala.bzl",
    "scala_library",
)
load(
    "@rules_scala//scala_native/private/rules:scala_native_library.bzl",
    "scala_native_library",
)
load(
    "@rules_scala//scala_native/private/rules:scala_native_binary.bzl",
    "scala_native_binary",
)

scala_native_library(
    name = "greetings",
    srcs = ["Greetings.scala"],
)

scala_native_library(
    name = "hello_native",
    srcs = [
        "HelloNative.scala",
    ],
    deps = [
        ":greetings",
    ],
)

scala_native_library(
    name = "intrinsics",
    srcs = [
        "Intrinsics.scala",
    ],
)

scala_native_binary(
    name = "hello_native_bin",
    main_class = "examples.native.sayHello",
    deps = [
        ":hello_native",
    ],
)
