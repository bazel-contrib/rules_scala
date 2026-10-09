load(
    "@rules_scala//scala:scala_cross_version.bzl",
    "default_maven_server_urls",
    "extract_major_version",
)
load(
    "@rules_scala//scala:scala_maven_import_external.bzl",
    "scala_maven_import_external",
)
load(
    "@rules_scala//third_party/repositories:repositories.bzl",
    "artifacts_by_major_scala_version",
)
load(
    "@rules_scala//third_party/repositories:scala_2_13.bzl",
    _scala_2_version = "scala_version",
)
load(
    "@rules_scala//third_party/repositories:scala_3_8.bzl",
    _scala_3_version = "scala_version",
)
load("@rules_scala_config//:config.bzl", "SCALA_VERSION")

# Repo name in this test -> key in third_party/repositories/scala_<major>_<minor>.bzl.
_UPSTREAM_ASM = {
    "asm": "io_bazel_rules_scala_org_ow2_asm_asm",
    "asm_analysis": "io_bazel_rules_scala_org_ow2_asm_asm_analysis",
    "asm_commons": "io_bazel_rules_scala_org_ow2_asm_asm_commons",
    "asm_tree": "io_bazel_rules_scala_org_ow2_asm_asm_tree",
    "asm_util": "io_bazel_rules_scala_org_ow2_asm_asm_util",
}

_IS_SCALA_2 = SCALA_VERSION.startswith("2.")
_IS_SCALA_3 = SCALA_VERSION.startswith("3.")

_SCALA_2_VERSION = SCALA_VERSION if _IS_SCALA_2 else _scala_2_version
_SCALA_3_VERSION = SCALA_VERSION if _IS_SCALA_3 else _scala_3_version

def _minor_version(version):
    base = version.split("-")[0]
    parts = base.split(".")
    return int(parts[1])

# Scala 3.0 - 3.7 use Scala 2.13 standard library
# Starting Scala 3.8 scala3-library_3 is an empty jar, scala-library is used instead
_SCALA_3_AT_LEAST_3_8 = _IS_SCALA_3 and _minor_version(SCALA_VERSION) >= 8
_SCALA_LIBRARY_VERSION = (
    SCALA_VERSION if (_IS_SCALA_2 or _SCALA_3_AT_LEAST_3_8) else _SCALA_2_VERSION
)

_SCALA_2_ARTIFACTS = {
    "scala_reflect": "org.scala-lang:scala-reflect:",
}

_SCALA_3_ARTIFACTS = {
    "scala3_library": "org.scala-lang:scala3-library_3:",
    "scala3_interfaces": "org.scala-lang:scala3-interfaces:",
    "tasty_core": "org.scala-lang:tasty-core_3:",
}

def _versioned_artifacts(scala_version, artifacts):
    return {k: v + scala_version for k, v in artifacts.items()}

def _has_upstream_asm(artifacts):
    for key in _UPSTREAM_ASM.values():
        if key not in artifacts:
            return False
    return True

def _upstream_asm_artifacts():
    """org.ow2.asm coordinates published with the Scala compiler under test.

    Scala 3.10+ scalac calls these instead of shaded scala-asm. The versions
    are taken from the generated repository metadata so they follow the compiler.
    """
    selected = {}
    if _IS_SCALA_3:
        selected = artifacts_by_major_scala_version.get(extract_major_version(SCALA_VERSION), {})
    if not _has_upstream_asm(selected):
        selected = {}
        best_minor = -1
        for major, artifacts in artifacts_by_major_scala_version.items():
            if not major.startswith("3.") or not _has_upstream_asm(artifacts):
                continue
            minor = int(major.split(".")[1])
            if minor > best_minor:
                best_minor = minor
                selected = artifacts
    if not selected:
        fail("no registered Scala version publishes org.ow2.asm artifacts")
    return {
        repo: selected[key]["artifact"]
        for repo, key in _UPSTREAM_ASM.items()
    }

COMPILER_SOURCES_ARTIFACTS = (
    _versioned_artifacts(SCALA_VERSION, {
        "scala_compiler": "org.scala-lang:scala3-compiler_3:" if _IS_SCALA_3 else "org.scala-lang:scala-compiler:",
    }) |
    _versioned_artifacts(_SCALA_LIBRARY_VERSION, {
        "scala_library": "org.scala-lang:scala-library:",
    }) |
    _versioned_artifacts(_SCALA_2_VERSION, _SCALA_2_ARTIFACTS) |
    _versioned_artifacts(_SCALA_3_VERSION, _SCALA_3_ARTIFACTS) |
    {
        "sbt_compiler_interface": "org.scala-sbt:compiler-interface:1.9.6",
        "scala_asm": "org.scala-lang.modules:scala-asm:9.7.0-scala-2",
    } |
    _upstream_asm_artifacts()
)

def import_compiler_source_repos():
    for name, artifact in COMPILER_SOURCES_ARTIFACTS.items():
        scala_maven_import_external(
            name = name,
            artifact = artifact,
            licenses = ["notice"],
            server_urls = default_maven_server_urls(),
        )

def _compiler_source_repos_impl(_ctx):
    import_compiler_source_repos()

compiler_source_repos = module_extension(
    implementation = _compiler_source_repos_impl,
)
