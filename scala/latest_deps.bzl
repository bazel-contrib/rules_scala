"""Macro for instantiating repos required for core functionality."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//scala/private:macros/workspace_compat.bzl", "workspace_compat")

def rules_scala_dependencies():
    """Instantiates repos needed by rules provided by `rules_scala`."""
    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "51b5105a760b353773f904d2bbc5e664d0987fbaf22265164de65d43e910d8ac",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.8.1/bazel-skylib-1.8.1.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.8.1/bazel-skylib-1.8.1.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "platforms",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/platforms/releases/download/1.0.0/platforms-1.0.0.tar.gz",
            "https://github.com/bazelbuild/platforms/releases/download/1.0.0/platforms-1.0.0.tar.gz",
        ],
        sha256 = "3384eb1c30762704fbe38e440204e114154086c8fc8a8c2e3e28441028c019a8",
    )

    maybe(
        http_archive,
        name = "rules_java",
        urls = [
            "https://github.com/bazelbuild/rules_java/releases/download/8.15.2/rules_java-8.15.2.tar.gz",
        ],
        sha256 = "47632cc506c858011853073449801d648e10483d4b50e080ec2549a4b2398960",
    )

    maybe(
        http_archive,
        name = "com_google_protobuf",
        sha256 = "3ad017543e502ffaa9cd1f4bd4fe96cf117ce7175970f191705fa0518aff80cd",
        strip_prefix = "protobuf-32.0",
        url = "https://github.com/protocolbuffers/protobuf/archive/refs/tags/v32.0.tar.gz",
        patches = [Label("//protoc:0001-protobuf-19679-rm-protoc-dep.patch")],
        patch_args = ["-p1"],
    )

    maybe(
        http_archive,
        name = "rules_proto",
        sha256 = "14a225870ab4e91869652cfd69ef2028277fc1dc4910d65d353b62d6e0ae21f4",
        strip_prefix = "rules_proto-7.1.0",
        url = "https://github.com/bazelbuild/rules_proto/releases/download/7.1.0/rules_proto-7.1.0.tar.gz",
    )

    maybe(
        http_archive,
        name = "rules_python",
        sha256 = "3664a03376fc2441e2dec357000b3a80119e2ea062ea1be41418daeb91451055",
        strip_prefix = "rules_python-1.6.0-rc0",
        url = "https://github.com/bazel-contrib/rules_python/releases/download/1.6.0-rc0/rules_python-1.6.0-rc0.tar.gz",
    )

    maybe(
        http_archive,
        name = "rules_shell",
        sha256 = "fce2a7a974aa70e9367068122e19c39a6a27a5aca30698bcf9030beb529612b6",
        strip_prefix = "rules_shell-0.6.0",
        url = "https://github.com/bazelbuild/rules_shell/releases/download/v0.6.0/rules_shell-v0.6.0.tar.gz",
    )

    workspace_compat()
