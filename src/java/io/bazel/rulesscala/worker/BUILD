load("@com_google_protobuf//bazel:java_proto_library.bzl", "java_proto_library")
load("@rules_java//java:defs.bzl", "java_library", "java_test")

java_library(
    name = "worker",
    srcs = ["Worker.java"],
    visibility = ["//visibility:public"],
    deps = [
        ":worker_protocol_java_proto",
    ],
)

java_test(
    name = "worker_test",
    srcs = [
        "WorkerTest.java",
    ],
    jvm_flags = [
        "-Dcom.google.testing.junit.runner.shouldInstallTestSecurityManager=false",
    ],
    test_class = "io.bazel.rulesscala.worker.WorkerTest",
    deps = [
        ":worker",
        ":worker_protocol_java_proto",
    ],
)

# Duplicated from @bazel_worker_java//:worker_protocol_java_proto to resolve:
# https://github.com/bazelbuild/bazel-worker-api/issues/7#issuecomment-3209882184
#
# rules_scala doesn't need anything else from @bazel_worker_java, so this
# sidesteps the issue.
java_proto_library(
    name = "worker_protocol_java_proto",
    deps = ["@bazel_worker_api//:worker_protocol_proto"],
)
