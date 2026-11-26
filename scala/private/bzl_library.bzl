"""`bzl_library` targets for the `.bzl` files of a package."""

load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

def bzl_libraries(srcs = None, names = {}, skip_docs = []):
    """Declares `bzl_library` targets for the `.bzl` files of this package.

    Declares a `bzl_srcs` filegroup with all `srcs`, for `//:all_bzl`. Each
    file outside a `private` directory also gets a `bzl_library` target that
    depends on `//:all_bzl`, and a `starlark_doc_extract` target.
    `starlark_doc_extract` fails at analysis when `//:all_bzl` misses a module
    that the file loads, so `bazel build //... --nobuild` finds it.

    Args:
        srcs: the `.bzl` files; the `.bzl` files directly in the package
            directory by default
        names: maps a file to its target name when the default name, the file
            path without `.bzl`, is already in use
        skip_docs: files that load a module that is visible only inside
            another repository
    """
    if srcs == None:
        srcs = native.glob(["*.bzl"])
    native.filegroup(
        name = "bzl_srcs",
        srcs = srcs,
        visibility = ["//:__pkg__"],
    )
    for src in srcs:
        if "private" in (native.package_name() + "/" + src).split("/"):
            continue
        name = names.get(src, src.removesuffix(".bzl"))
        bzl_library(
            name = name,
            srcs = [src],
            visibility = ["//visibility:public"],
            deps = ["//:all_bzl"],
        )
        if src not in skip_docs:
            native.starlark_doc_extract(
                name = name + "_doc",
                src = src,
                deps = [name],
            )
