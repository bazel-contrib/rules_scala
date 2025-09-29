load(
    "@rules_scala_artifacts//:artifacts.bzl",
    "jmh_core_artifacts",
    "jmh_classpath_artifacts",
    "benchmark_generator_artifacts",
    "benchmark_generator_runtime_artifacts",
)
load("@rules_scala_config//:config.bzl", "SCALA_VERSION")
load("//scala:providers.bzl", "declare_deps_provider", _DepsInfo = "DepsInfo")
load("//scala:scala_cross_version.bzl", "artifact_targets_for_scala_version")
load("//scala/private/toolchain_deps:toolchain_deps.bzl", "expose_toolchain_deps")

DEP_PROVIDERS = [
    "jmh_classpath",
    "jmh_core",
    "benchmark_generator",
    "benchmark_generator_runtime",
]

def _jmh_toolchain_impl(ctx):
    toolchain = platform_common.ToolchainInfo(
        dep_providers = ctx.attr.dep_providers,
    )
    return [toolchain]

jmh_toolchain = rule(
    _jmh_toolchain_impl,
    attrs = {
        "dep_providers": attr.label_list(
            default = [":%s_provider" % p for p in DEP_PROVIDERS],
            providers = [_DepsInfo],
        ),
    },
)

_toolchain_type = "//jmh/toolchain:jmh_toolchain_type"

def _export_toolchain_deps_impl(ctx):
    return expose_toolchain_deps(ctx, _toolchain_type)

export_toolchain_deps = rule(
    _export_toolchain_deps_impl,
    attrs = {
        "deps_id": attr.string(
            mandatory = True,
        ),
    },
    toolchains = [_toolchain_type],
)

def setup_jmh_toolchain(name):
    jmh_toolchain(
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
        name = "jmh_core_provider",
        deps_id = "jmh_core",
        visibility = ["//visibility:public"],
        deps = artifact_targets_for_scala_version(SCALA_VERSION, jmh_core_artifacts),
    )

    declare_deps_provider(
        name = "jmh_classpath_provider",
        deps_id = "jmh_classpath",
        visibility = ["//visibility:public"],
        deps = artifact_targets_for_scala_version(SCALA_VERSION, jmh_classpath_artifacts),
    )

    declare_deps_provider(
        name = "benchmark_generator_provider",
        deps_id = "benchmark_generator",
        visibility = ["//visibility:public"],
        deps = [
            Label("//src/java/io/bazel/rulesscala/jar"),
        ] + artifact_targets_for_scala_version(SCALA_VERSION, benchmark_generator_artifacts),
    )

    declare_deps_provider(
        name = "benchmark_generator_runtime_provider",
        deps_id = "benchmark_generator_runtime",
        visibility = ["//visibility:public"],
        deps = artifact_targets_for_scala_version(SCALA_VERSION, benchmark_generator_runtime_artifacts),
    )
