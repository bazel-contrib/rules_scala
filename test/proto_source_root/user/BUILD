load("@rules_proto//proto:defs.bzl", "proto_library")
load(
    "//scala_proto:scala_proto.bzl",
    "scala_proto_library",
)

proto_library(
    name = "user",
    srcs = glob(["*.proto"]),
    strip_import_prefix = "",
    deps = ["//test/proto_source_root/dependency"],
)

# Tagged "manual" so wildcard builds skip it; built by //test/proto_source_root.
scala_proto_library(
    name = "user_scala",
    tags = ["manual"],
    visibility = ["//visibility:public"],
    deps = [":user"],
)
