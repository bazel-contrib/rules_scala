"""Utilities required for dependency compatibility tests."""

load("@rules_scala//scala:advanced_usage/scala.bzl", "make_scala_test")
load("@rules_scala//scala/scalafmt:phase_scalafmt_ext.bzl", "ext_scalafmt")

# From //test/scalafmt:phase_scalafmt_test.bzl
scalafmt_scala_test = make_scala_test(ext_scalafmt)
