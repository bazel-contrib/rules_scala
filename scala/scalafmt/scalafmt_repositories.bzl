load(
    "@rules_scala_artifacts//:artifacts.bzl",
    "scalafmt_deps_2_11_artifacts",
    "scalafmt_deps_2_12_artifacts",
    "scalafmt_deps_after_2_11_artifacts",
    "scalafmt_deps_after_2_12_artifacts",
    "scalafmt_deps_artifacts",
    "scalapb_compile_deps_artifacts"
)
load("//scala:scala_cross_version.bzl", "artifact_targets_for_scala_version", "extract_major_version")
load("//scala_proto/default:repositories.bzl", "SCALAPB_COMPILE_ARTIFACT_IDS")

def scalafmt_artifact_ids(scala_version):
    major_version = extract_major_version(scala_version)

    if major_version == "2.11":
        return artifact_targets_for_scala_version(
            scala_version,
            scalafmt_deps_artifacts + scalapb_compile_deps_artifacts + scalafmt_deps_2_11_artifacts,
        )

    if major_version == "2.12":
        extra_deps = scalafmt_deps_2_12_artifacts
    else:
        extra_deps = scalafmt_deps_after_2_12_artifacts

    return artifact_targets_for_scala_version(
        scala_version,
        scalafmt_deps_artifacts + scalapb_compile_deps_artifacts + scalafmt_deps_after_2_11_artifacts + extra_deps,
    )
