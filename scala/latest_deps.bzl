"""Macro for instantiating repos required for core functionality."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//scala/private:macros/workspace_compat.bzl", "workspace_compat")

def rules_scala_dependencies():
    """Instantiates repos needed by rules provided by `rules_scala`."""
    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "6e78f0e57de26801f6f564fa7c4a48dc8b36873e416257a92bbb0937eeac8446",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.8.2/bazel-skylib-1.8.2.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.8.2/bazel-skylib-1.8.2.tar.gz",
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
            "https://github.com/bazelbuild/rules_java/releases/download/8.16.1/rules_java-8.16.1.tar.gz",
        ],
        sha256 = "1b30698d89dccd9dc01b1a4ad7e9e5c6e669cdf1918dbb050334e365b40a1b5e",
    )

    # Required before `rules_java_dependencies` since `rules_java` 8.16.0.
    maybe(
        http_archive,
        name = "bazel_features",
        sha256 = "07271d0f6b12633777b69020c4cb1eb67b1939c0cf84bb3944dc85cc250c0c01",
        strip_prefix = "bazel_features-1.38.0",
        url = "https://github.com/bazel-contrib/bazel_features/releases/download/v1.38.0/bazel_features-v1.38.0.tar.gz",
    )

    maybe(
        http_archive,
        name = "com_google_protobuf",
        sha256 = "b6b03fbaa3a90f3d4f2a3fa4ecc41d7cd0326f92fcc920a7843f12206c8d52cd",
        strip_prefix = "protobuf-33.0",
        url = "https://github.com/protocolbuffers/protobuf/archive/refs/tags/v33.0.tar.gz",
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
        sha256 = "2f5c284fbb4e86045c2632d3573fc006facbca5d1fa02976e89dc0cd5488b590",
        strip_prefix = "rules_python-1.6.3",
        url = "https://github.com/bazel-contrib/rules_python/releases/download/1.6.3/rules_python-1.6.3.tar.gz",
    )

    maybe(
        http_archive,
        name = "rules_shell",
        sha256 = "e6b87c89bd0b27039e3af2c5da01147452f240f75d505f5b6880874f31036307",
        strip_prefix = "rules_shell-0.6.1",
        url = "https://github.com/bazelbuild/rules_shell/releases/download/v0.6.1/rules_shell-v0.6.1.tar.gz",
    )

    workspace_compat()
