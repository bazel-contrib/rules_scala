load("//scala:scala_toolchain.bzl", "scala_toolchain")

# The targets below are only exercised by the manual coverage test
# (manual_test/coverage_local_jacocorunner/test.sh), which first builds
# JacocoCoverage_jarjar_deploy.jar out-of-band and copies it into this package.
# They are tagged "manual" so wildcard builds (e.g. `bazel build //...`) don't
# try to build the not-yet-present jar, while explicit references such as the
# test's `--extra_toolchains=//manual_test/...` still resolve.
scala_toolchain(
    name = "local_jacocorunner_toolchain_impl",
    jacocorunner = ":local_jacocorunner",
    tags = ["manual"],
    visibility = ["//visibility:public"],
)

toolchain(
    name = "local_jacocorunner_scala_toolchain",
    tags = ["manual"],
    toolchain = "local_jacocorunner_toolchain_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//visibility:public"],
)

filegroup(
    name = "local_jacocorunner",
    srcs = ["JacocoCoverage_jarjar_deploy.jar"],
    tags = ["manual"],
)
