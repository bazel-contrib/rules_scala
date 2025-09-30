load(
    "@rules_scala_artifacts//:artifacts.bzl",
    "scopt_artifacts",
    "scrooge_core_artifacts",
    "scrooge_generator_artifacts",
    "util_core_artifacts",
    "util_logging_artifacts",
)
load("@rules_scala_config//:config.bzl", "SCALA_VERSION")
load("//scala:providers.bzl", "DepsInfo", "declare_deps_provider")
load("//scala:scala_cross_version.bzl", "artifact_targets_for_scala_version")
load(
    "//scala/private/toolchain_deps:toolchain_deps.bzl",
    "expose_toolchain_deps",
)

DEP_PROVIDERS = [
    "compile_classpath",
    "aspect_compile_classpath",
    "scrooge_generator_classpath",
    "compiler_classpath",
]

def _scrooge_toolchain_impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        dep_providers = ctx.attr.dep_providers,
    )
    return [toolchain]

scrooge_toolchain = rule(
    _scrooge_toolchain_impl,
    attrs = {
        "dep_providers": attr.label_list(
            providers = [DepsInfo],
        ),
    },
)

_toolchain_type = "//twitter_scrooge/toolchain:scrooge_toolchain_type"

def _export_scrooge_deps_impl(ctx):
    return expose_toolchain_deps(ctx, _toolchain_type)

export_scrooge_deps = rule(
    _export_scrooge_deps_impl,
    attrs = {
        "deps_id": attr.string(
            mandatory = True,
        ),
    },
    toolchains = [_toolchain_type],
)

TOOLCHAIN_DEFAULTS = {
    "libthrift": None,
    "scrooge_core": None,
    "scrooge_generator": None,
    "util_core": None,
    "util_logging": None,
    "javax_annotation_api": None,
    "mustache": None,
    "scopt": None,
}

def setup_scrooge_toolchain(
        name,
        libthrift = None,
        scrooge_core = None,
        scrooge_generator = None,
        util_core = None,
        util_logging = None,
        javax_annotation_api = None,
        mustache = None,
        scopt = None):
    if libthrift == None:
        # We use the canonical repository name so it resolves in workspaces other than this one
        libthrift = "@@rules_jvm_external++maven+rules_scala_maven//:org_apache_thrift_libthrift"
    if scrooge_core == None:
        scrooge_core = artifact_targets_for_scala_version(SCALA_VERSION, scrooge_core_artifacts)[0]
    if scrooge_generator == None:
        scrooge_generator = artifact_targets_for_scala_version(SCALA_VERSION, scrooge_generator_artifacts)[0]
    if util_core == None:
        util_core = artifact_targets_for_scala_version(SCALA_VERSION, util_core_artifacts)[0]
    if util_logging == None:
        util_logging = artifact_targets_for_scala_version(SCALA_VERSION, util_logging_artifacts)[0]
    if javax_annotation_api == None:
        # We use the canonical repository name so it resolves in workspaces other than this one
        javax_annotation_api = "@@rules_jvm_external++maven+rules_scala_maven//:javax_annotation_javax_annotation_api"
    if mustache == None:
        # We use the canonical repository name so it resolves in workspaces other than this one
        mustache = "@@rules_jvm_external++maven+rules_scala_maven//:com_github_spullara_mustache_java_compiler"
    if scopt == None:
        scopt = artifact_targets_for_scala_version(SCALA_VERSION, scopt_artifacts)[0]

    scrooge_toolchain(
        name = "%s_impl" % name,
        dep_providers = [":%s_provider" % p for p in DEP_PROVIDERS],
        visibility = ["//visibility:public"],
    )

    native.toolchain(
        name = name,
        toolchain = ":%s_impl" % name,
        toolchain_type = Label(_toolchain_type),
        visibility = ["//visibility:public"],
    )

    declare_deps_provider(
        name = "aspect_compile_classpath_provider",
        deps_id = "aspect_compile_classpath",
        visibility = ["//visibility:public"],
        deps = [
            javax_annotation_api,
            Label("//scala/private/toolchain_deps:scala_library_classpath"),
            libthrift,
            scrooge_core,
            util_core,
        ],
    )

    declare_deps_provider(
        name = "compile_classpath_provider",
        deps_id = "compile_classpath",
        visibility = ["//visibility:public"],
        deps = [
            Label("//scala/private/toolchain_deps:scala_library_classpath"),
            libthrift,
            scrooge_core,
        ],
    )

    declare_deps_provider(
        name = "scrooge_generator_classpath_provider",
        deps_id = "scrooge_generator_classpath",
        visibility = ["//visibility:public"],
        deps = [scrooge_generator],
    )

    declare_deps_provider(
        name = "compiler_classpath_provider",
        deps_id = "compiler_classpath",
        visibility = ["//visibility:public"],
        deps = [
            mustache,
            scopt,
            Label("//scala/private/toolchain_deps:parser_combinators"),
            scrooge_generator,
            util_core,
            util_logging,
        ],
    )
