"""`bzl_library` that also checks its `deps`."""

load("@bazel_skylib//:bzl_library.bzl", _bzl_library = "bzl_library")

def bzl_library(name, srcs, extract_docs = True, **kwargs):
    """Declares a skylib `bzl_library` and a `starlark_doc_extract` for each file in `srcs`.

    `starlark_doc_extract` fails at analysis when `deps` miss a module that a
    file in `srcs` loads, so `bazel build //... --nobuild` finds missing
    `deps`.

    Args:
        name: the `bzl_library` name
        srcs: the `.bzl` files
        extract_docs: set to `False` when a module that `srcs` load is
            visible only inside another repository
        **kwargs: other `bzl_library` attributes
    """
    _bzl_library(name = name, srcs = srcs, **kwargs)
    if not extract_docs:
        return
    for src in srcs:
        native.starlark_doc_extract(
            name = src.removesuffix(".bzl") + "_doc",
            src = src,
            deps = [name],
        )
