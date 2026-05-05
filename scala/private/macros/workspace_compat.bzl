"""Macro to translate Bazel modules into legacy WORKSPACE compatible repos

Used only for Bazel modules that don't offer a legacy WORKSPACE compatible API
already. Originally became necessary due to:

- https://github.com/bazelbuild/bazel/issues/26579#issuecomment-3120862995
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def _bazel_worker_api_repo(name, strip_prefix):
    """See //src/java/io/bazel/rulesscala/worker:worker_protocol_java_proto."""
    maybe(
        http_archive,
        name = name,
        sha256 = "0476fe27251cd3234b69737f8bc231cfe9912becdd620e07e2d73c87bcc7e40a",
        urls = [
            "https://github.com/bazelbuild/bazel-worker-api/releases/download/v0.0.10/bazel-worker-api-v0.0.10.tar.gz",
        ],
        strip_prefix = "bazel-worker-api-0.0.10/" + strip_prefix,
    )

def workspace_compat():
    _bazel_worker_api_repo(
        name = "bazel_worker_api",
        strip_prefix = "proto",
    )
