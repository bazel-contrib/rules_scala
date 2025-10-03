# Development helper scripts

## [`sync_bazelversion.sh`](./sync-bazelversion.sh)

Synchronizes all of the `.bazelversion` files in the project with the top level
`.bazelversion`.

The [bazelisk](https://github.com/bazelbuild/bazelisk) wrapper for Bazel uses
`.bazelversion` files select a Bazel version. While `USE_BAZEL_VERSION` can
also override the Bazel version, keeping the `.bazelversion` files synchronized
helps avoid suprises when not using `USE_BAZEL_VERSION`.

## [`update_protoc_integrity.py`](./update_protoc_integrity.py)

Updates [`protoc/private/protoc_integrity.bzl`](
../protoc/private/protoc_integrity.bzl).

Upon a new release of
[`protocolbuffers/protobuf`](https://github.com/protocolbuffers/protobuf/releases)
add the new version to the `PROTOC_VERSIONS` at the top of this file and run it.

## [`update_compiler_sources_integrity.py`][]

Updates [`scala/private/macros/compiler_sources_integrity.bzl`](
../scala/private/macros/compiler_sources_integrity.bzl).

Upon a new [Scala version release](https://www.scala-lang.org/download/all.html),
add the new version to the `SCALA_VERSIONS` at the top of this file and run it.

[`update_compiler_sources_integrity.py`]:
    ./update_compiler_sources_integrity.py
