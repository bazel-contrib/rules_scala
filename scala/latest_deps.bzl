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
            "https://github.com/bazelbuild/rules_java/releases/download/8.15.0/rules_java-8.15.0.tar.gz",
        ],
        sha256 = "0a7e8811cac04b553f6c6c0d185046e3c68a4cb774e83f37a7a5fb6a3deee261",
    )

    maybe(
        http_archive,
        name = "com_google_protobuf",
        sha256 = "c3a0a9ece8932e31c3b736e2db18b1c42e7070cd9b881388b26d01aa71e24ca2",
        strip_prefix = "protobuf-31.1",
        url = "https://github.com/protocolbuffers/protobuf/archive/refs/tags/v31.1.tar.gz",
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

    # Resolves the following error when building under `WORKSPACE` with Bazel 8.2.1,
    # `protobuf` v31.1, and `rules_java` 8.12.0:
    # https://github.com/protocolbuffers/protobuf/pull/19129#issuecomment-2968934424
    rules_jvm_external_tag = "6.8"
    rules_jvm_external_sha = (
        "704a0197e4e966f96993260418f2542568198490456c21814f647ae7091f56f2"
    )
    maybe(
        http_archive,
        name = "rules_jvm_external",
        sha256 = rules_jvm_external_sha,
        strip_prefix = "rules_jvm_external-%s" % rules_jvm_external_tag,
        url = "https://github.com/bazel-contrib/rules_jvm_external/releases/download/%s/rules_jvm_external-%s.tar.gz" % (
            rules_jvm_external_tag,
            rules_jvm_external_tag,
        ),
    )

    # Can't upgrade for now because https://github.com/bazel-contrib/rules_python/pull/2760
    # broke Bazel 7 WORKSPACE builds. It's really only a dev dep anyway.
    # If it's fixed per https://github.com/bazel-contrib/rules_python/issues/3119
    # (i.e., once https://github.com/bazel-contrib/rules_python/pull/3134 lands),
    # then we can upgrade.
    maybe(
        http_archive,
        name = "rules_python",
        sha256 = "9f9f3b300a9264e4c77999312ce663be5dee9a56e361a1f6fe7ec60e1beef9a3",
        strip_prefix = "rules_python-1.4.1",
        url = "https://github.com/bazelbuild/rules_python/releases/download/1.4.1/rules_python-1.4.1.tar.gz",
    )

    maybe(
        http_archive,
        name = "rules_shell",
        sha256 = "99bfc7aaefd1ed69613bbd25e24bf7871d68aeafca3a6b79f5f85c0996a41355",
        strip_prefix = "rules_shell-0.5.1",
        url = "https://github.com/bazelbuild/rules_shell/releases/download/v0.5.1/rules_shell-v0.5.1.tar.gz",
    )

    workspace_compat()
