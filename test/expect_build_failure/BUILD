# Shared helpers for asserting on the outcome of a `bazel build` (which Bazel
# has no native rule for): expect_build_failure.sh drives the assertion, and
# nested_bazel.sh holds the common nested-`bazel` runner it (and other build-
# outcome tests, e.g. //test/macros:expect_no_ijar.sh) source at runtime.
exports_files(
    [
        "expect_build_failure.sh",
        "nested_bazel.sh",
    ],
    visibility = ["//visibility:public"],
)
