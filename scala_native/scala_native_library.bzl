"""Public API for scala_native_library rule."""

load(
    "//scala_native/private/rules:scala_native_library.bzl",
    _scala_native_library = "scala_native_library",
)

scala_native_library = _scala_native_library
