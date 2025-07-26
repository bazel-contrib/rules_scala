"""Macro to translate Bazel modules into legacy WORKSPACE compatible repos

Used only for Bazel modules that don't offer a legacy WORKSPACE compatible API
already. Originally became necessary due to:

- https://github.com/bazelbuild/bazel/issues/26579#issuecomment-3120862995
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

_ALIAS_REPO_BUILD_FMT = """\
package(default_visibility = ["//visibility:public"])

{aliases}"""

_ALIAS_FMT = """\
alias(
    name = "{name}",
    actual = "{actual}",
)
"""

def _alias_repo_impl(repository_ctx):
    aliases = "\n".join([
        _ALIAS_FMT.format(name = name, actual = actual)
        for name, actual in repository_ctx.attr.aliases.items()
    ])
    repository_ctx.file(
        "BUILD",
        _ALIAS_REPO_BUILD_FMT.format(aliases = aliases),
        executable = False,
    )

_alias_repo = repository_rule(
    implementation = _alias_repo_impl,
    attrs = {"aliases": attr.string_dict(mandatory = True)},
)

def workspace_compat():
    maybe(
        http_archive,
        name = "bazel-worker-api",
        sha256 = "07b5fa9c883558e378a00c67dae05a4dcb8d43cc12486722d6875224454a8a30",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-worker-api/releases/download/v0.0.5/bazel-worker-api-v0.0.5.tar.gz",
            "https://github.com/bazelbuild/bazel-worker-api/releases/download/v0.0.5/bazel-worker-api-v0.0.5.tar.gz",
        ],
        strip_prefix = "bazel-worker-api-0.0.5",
    )

    _alias_repo(
        name = "bazel_worker_api",
        aliases = {
            "worker_protocol_proto": "@bazel-worker-api//proto:worker_protocol_proto",
        },
    )

    _alias_repo(
        name = "bazel_worker_java",
        aliases = {
            "worker_protocol_java_proto": "@bazel-worker-api//java:worker_protocol_java_proto",
        },
    )
