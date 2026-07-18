load("//scala_proto:scala_proto.bzl", "scala_proto_library")
load("//twitter_scrooge:twitter_scrooge.bzl", "scrooge_scala_library")

# scala_proto_library and scrooge_scala_library run Scalac inside an aspect.
# Bazel doesn't propagate target-level exec_properties to aspect actions, so
# these rules intentionally do NOT declare the "scalac" exec_group — a user
# setting scalac.* here would silently drop the value. The lack of the
# exec_group turns that silent drop into an analysis-time error.
# See docs/scalac_exec_group.md and test/shell/test_scalac_exec_group.sh.

scala_proto_library(
    name = "scala_proto_library_with_scalac_exec_property",
    exec_properties = {"scalac.cpu": "1"},
    deps = ["//test/proto3:generated-proto-lib"],
)

scrooge_scala_library(
    name = "scrooge_scala_library_with_scalac_exec_property",
    exec_properties = {"scalac.cpu": "1"},
    deps = ["//test/src/main/scala/scalarules/test/twitter_scrooge/thrift"],
)
