def _create_toolchain_metadata_rule_impl(repository_ctx):
    repository_ctx.file(
        "artifacts.bzl",
        content = repository_ctx.attr.content,
        executable = False,
    )

    repository_ctx.file(
        "BUILD",
        content = 'exports_files(["artifacts.bzl"])\n',
        executable = False,
    )

_create_toolchain_metadata_rule = repository_rule(
    attrs = {
        "content": attr.string(mandatory = True),
    },
    implementation = _create_toolchain_metadata_rule_impl,
)

_artifact = tag_class(
    attrs = {
        "group": attr.string(
            doc = "The Maven group ID.",
            mandatory = True,
        ),
        "name": attr.string(
            doc = "The Maven artifact ID.",
            mandatory = True,
        ),
        "scala_version": attr.string(doc = "The version of Scala this artifact was build with."),
        "toolchain_name": attr.string(
            doc = "The name of the toolchain this artifact belongs to.",
            mandatory = True,
        ),
    },
    doc = "Define metadata for a Maven artifact belonging to a toolchain.",
)

def _create_toolchain_metadata_impl(module_ctx):
    artifacts_by_toolchain = {}

    for module in module_ctx.modules:
        for tag in module.tags.artifact:
            if tag.toolchain_name not in artifacts_by_toolchain:
                artifacts_by_toolchain[tag.toolchain_name] = []

            artifacts_by_toolchain[tag.toolchain_name].append(
                struct(
                    group = tag.group,
                    name = tag.name,
                    scala_version = tag.scala_version,
                )
            )

    _create_toolchain_metadata_rule(
        name = "rules_scala_artifacts",
        content = "".join([
            "{}_artifacts = {}\n".format(toolchain_name, artifacts)
            for toolchain_name, artifacts in artifacts_by_toolchain.items()
        ]),
    )

create_toolchain_metadata = module_extension(
    implementation = _create_toolchain_metadata_impl,
    tag_classes = {
        "artifact": _artifact,
    },
)
