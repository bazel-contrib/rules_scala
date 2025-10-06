# These are the compile/runtime dependencies needed for scalapb compilation
# and grpc compile/runtime.
#
# In a complex environment you may want to update the toolchain to not refer to
# these anymore If you are using a resolver (like bazel-deps) that can export
# compile + runtime jar paths for you, then you should only need much shorter
# dependency lists. This needs to be the unrolled transitive path to be used
# without such a facility.

load(
    "@rules_scala_artifacts//:artifacts.bzl",
    "scalapb_compile_deps_artifacts",
    "scalapb_grpc_deps_artifacts",
    "scalapb_worker_deps_artifacts",
)
load("@rules_scala_config//:config.bzl", "SCALA_VERSION")
load("//scala:scala_cross_version.bzl", "artifact_targets_for_scala_version")

_DEFAULT_DEP_PROVIDER_FORMAT = (
    "@rules_scala_toolchains//scala_proto:scalapb_%s_deps_provider"
)

def scala_proto_deps_providers(
        compile = _DEFAULT_DEP_PROVIDER_FORMAT % "compile",
        worker = _DEFAULT_DEP_PROVIDER_FORMAT % "worker"):
    return [compile, worker]

DEFAULT_SCALAPB_COMPILE_DEPS = [
    Label("//scala/private/toolchain_deps:scala_library_classpath"),
    "@com_google_protobuf//:protobuf_java",
] + artifact_targets_for_scala_version(SCALA_VERSION, scalapb_compile_deps_artifacts)

DEFAULT_SCALAPB_GRPC_DEPS = artifact_targets_for_scala_version(SCALA_VERSION, scalapb_grpc_deps_artifacts)
DEFAULT_SCALAPB_WORKER_DEPS = ["@com_google_protobuf//:protobuf_java"] + artifact_targets_for_scala_version(
    SCALA_VERSION,
    scalapb_worker_deps_artifacts,
)
