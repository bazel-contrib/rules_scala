load("//scala:scala.bzl", "scala_library")
load(
    "//test/expect_build_failure:expect_build_failure.bzl",
    "expect_build_failure_test",
    "expect_build_success_test",
)

package(default_testonly = 1)

# Deliberately fails to compile (type error). Tagged "manual" so wildcard builds
# skip it; built by persistent_worker_failure to check the worker surfaces the error.
scala_library(
    name = "broken",
    srcs = ["Broken.scala"],
    tags = ["manual"],
)

expect_build_success_test(
    name = "persistent_worker_success",
    build_args = ["--strategy=Scalac=worker"],
    target = "//test:ScalaBinary",
    worker_sandboxing = True,
)

expect_build_failure_test(
    name = "persistent_worker_failure",
    build_args = ["--strategy=Scalac=worker"],
    target = ":broken",
    worker_sandboxing = True,
)
