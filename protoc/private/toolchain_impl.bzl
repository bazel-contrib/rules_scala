"""Prebuilt protoc toolchain utilities

Used to implement `--incompatible_enable_proto_toolchain_resolution`
compatibility. Inspired by:
https://github.com/protocolbuffers/protobuf/pull/19679
"""

load("@rules_proto//proto:proto_common.bzl", "toolchains")

PROTOC_TOOLCHAIN_ENABLED = not bool(toolchains.if_legacy_toolchain(True))

PROTOC_TOOLCHAIN_TYPE = Label("//protoc:toolchain_type")
PROTOC_FRAGMENTS = ["proto"]
PROTOC_ATTR = toolchains.if_legacy_toolchain({
    "_protoc": attr.label(
        allow_files = True,
        cfg = "exec",
        default = configuration_field("proto", "proto_compiler"),
        executable = True,
    ),
})

PROTOC_TOOLCHAINS = toolchains.use_toolchain(PROTOC_TOOLCHAIN_TYPE)

def protoc_executable(ctx):
    """Returns `protoc` executable path for rules using `PROTOC_*` symbols.

    Requires that rules use `PROTOC_ATTR`, `PROTOC_FRAGMENTS`, and
    `PROTOC_TOOLCHAINS` as follows:

    ```py
    attrs = {
        # ...other attrs...
    } | PROTOC_ATTR,
    fragments = PROTOC_FRAGMENTS,
    toolchains = PROTOC_TOOLCHAINS,
    ```

    Args:
        ctx: the rule context object

    Returns:
        the prebuilt `protoc` executable path from the prebuilt toolchain
        if `--incompatible_enable_proto_toolchain_resolution` is enabled,
        or the path to the `protoc` compiled by `protobuf` otherwise
    """

    if not PROTOC_TOOLCHAIN_ENABLED:
        return ctx.attr._protoc[DefaultInfo].files_to_run.executable

    toolchain = ctx.toolchains[PROTOC_TOOLCHAIN_TYPE]
    protoc = toolchain and toolchain.proto.proto_compiler.executable or None

    if protoc == None or protoc.owner == Label("@com_google_protobuf//:protoc"):
        fail(
            "Couldn't resolve prebuilt protocol compiler toolchain " +
            "for toolchain type: " + str(PROTOC_TOOLCHAIN_TYPE),
        )
    return protoc
