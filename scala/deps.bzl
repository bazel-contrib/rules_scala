"""Macro for instantiating repos required for core functionality."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//scala/private:macros/workspace_compat.bzl", "workspace_compat")

def rules_scala_dependencies():
    """Instantiates repos needed by rules provided by `rules_scala`."""
    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "fa01292859726603e3cd3a0f3f29625e68f4d2b165647c72908045027473e933",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.8.0/bazel-skylib-1.8.0.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.8.0/bazel-skylib-1.8.0.tar.gz",
        ],
    )

    maybe(
        http_archive,
        name = "platforms",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/platforms/releases/download/0.0.9/platforms-0.0.9.tar.gz",
            "https://github.com/bazelbuild/platforms/releases/download/0.0.9/platforms-0.0.9.tar.gz",
        ],
        sha256 = "5eda539c841265031c2f82d8ae7a3a6490bd62176e0c038fc469eabf91f6149b",
    )

    # If using `rules_java` between 7.6.0 and 8.4.0, the `WORKSPACE` statements
    # are different. See:
    # - https://github.com/bazelbuild/rules_java/releases/tag/7.6.0
    #maybe(
    #    http_archive,
    #    name = "rules_java",
    #    urls = [
    #        "https://github.com/bazelbuild/rules_java/releases/download/7.6.0/rules_java-7.6.0.tar.gz",
    #    ],
    #    sha256 = "1da22389fe688c515ed732d01a2b18f3961eb4431aec40dcbaa043b58ba7941e",
    #)

    maybe(
        http_archive,
        name = "rules_java",
        urls = [
            "https://github.com/bazelbuild/rules_java/releases/download/8.5.0/rules_java-8.5.0.tar.gz",
        ],
        sha256 = "5c215757b9a6c3dd5312a3cdc4896cef3f0c5b31db31baa8da0d988685d42ae4",
    )

    maybe(
        http_archive,
        name = "com_google_protobuf",
        sha256 = "136a07aad488cc502b11c4416fe4a7df2dfdea1d0833a7a8211000bf952728ba",
        strip_prefix = "protobuf-33.4",
        url = "https://github.com/protocolbuffers/protobuf/archive/refs/tags/v33.4.tar.gz",
    )

    # Outside macOS, Windows and Linux x86_64 (for example on Linux ARM64),
    # `rules_java` builds `one_version` from source, which needs
    # `@com_google_absl`. `protobuf_deps()` declares Abseil as `@abseil-cpp`.
    maybe(
        http_archive,
        name = "com_google_absl",
        integrity = "sha256-jF3/tZRlrthY/Y+cEgf1ljqPmtqNOcwVh392LHtERWA=",
        strip_prefix = "abseil-cpp-76bb24329e8bf5f39704eb10d21b9a80befa7c81",
        urls = ["https://github.com/abseil/abseil-cpp/archive/76bb24329e8bf5f39704eb10d21b9a80befa7c81.zip"],
    )

    workspace_compat()
