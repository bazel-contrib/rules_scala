load("//scala:scala.bzl", "scala_library")
load("//scala:scala_cross_version_select.bzl", "select_for_scala_version")

scala_library(
    name = "test_reporter",
    srcs = ["JUnitXmlReporter.scala"],
    scalacopts = [
        "-deprecation:true",
        "-encoding",
        "UTF-8",
        "-feature",
        "-language:implicitConversions",
        "-unchecked",
    ] + select_for_scala_version(
        any_2 = [
            "-Xfatal-warnings",
            "-Xlint",
            "-Ywarn-dead-code",
            "-Ywarn-numeric-widen",
            "-Ywarn-value-discard",
            "-language:existentials",
            "-language:higherKinds",
        ],
        any_2_13 = [
            "-Wunused:imports",
        ],
        any_3 = [
            "-Werror",
            "-Wvalue-discard",
        ],
        before_2_13 = [
            "-Yno-adapted-args",
            "-Xfuture",
            "-Ywarn-unused-import",
            "-Ypartial-unification",
        ],
    ),
    visibility = ["//visibility:public"],
    deps = [
        "//scala/private/toolchain_deps:scala_xml",
        "//testing/toolchain:scalatest_classpath",
    ],
)
