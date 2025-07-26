"""Macro to translate Bazel modules into legacy WORKSPACE compatible repos

Used only for Bazel modules that don't offer a legacy WORKSPACE compatible API
already. Originally became necessary due to:

- https://github.com/bazelbuild/bazel/issues/26579#issuecomment-3120862995
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def _bazel_worker_api_repo(name, strip_prefix):
    maybe(
        http_archive,
        name = name,
        sha256 = "5aac6ae6a23015cc7984492a114dc539effc244ec5ac7f8f6b1539c15fb376eb",
        urls = [
            "https://github.com/bazelbuild/bazel-worker-api/releases/download/v0.0.6/bazel-worker-api-v0.0.6.tar.gz",
        ],
        strip_prefix = "bazel-worker-api-0.0.6/" + strip_prefix,
    )

def workspace_compat():
    _bazel_worker_api_repo(
        name = "bazel_worker_api",
        strip_prefix = "proto",
    )

    _bazel_worker_api_repo(
        name = "bazel_worker_java",
        strip_prefix = "java",
    )
