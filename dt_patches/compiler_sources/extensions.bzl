load("@rules_jvm_external//:defs.bzl", "maven_install")
load(
    "@rules_scala//scala:scala_cross_version.bzl",
    "default_maven_server_urls",
)
load("@rules_scala_config//:config.bzl", "SCALA_VERSION")

_IS_SCALA_2 = SCALA_VERSION.startswith("2.")
_IS_SCALA_3 = SCALA_VERSION.startswith("3.")

_SCALA_VERSION_ARTIFACTS = [
    "org.scala-lang:scala3-compiler_3:",
    "org.scala-lang:scala3-library_3:",
] if _IS_SCALA_3 else [
    "org.scala-lang:scala-compiler:",
    "org.scala-lang:scala-library:",
]

_SCALA_2_ARTIFACTS = [
    "org.scala-lang:scala-reflect:",
    "org.scala-lang:scala-library:",
] if _IS_SCALA_2 else []

_SCALA_3_ARTIFACTS = [
    "org.scala-lang:scala3-interfaces:",
    "org.scala-lang:tasty-core_3:",
] if _IS_SCALA_3 else []

def _versioned_artifacts(scala_version, artifacts):
    return [artifact + scala_version for artifact in artifacts]

COMPILER_SOURCES_ARTIFACTS = (
    _versioned_artifacts(SCALA_VERSION, _SCALA_VERSION_ARTIFACTS) +
    _versioned_artifacts(SCALA_VERSION, _SCALA_2_ARTIFACTS) +
    _versioned_artifacts(SCALA_VERSION, _SCALA_3_ARTIFACTS) +
    [
        "org.scala-sbt:compiler-interface:1.9.6",
        "org.scala-lang.modules:scala-asm:9.7.0-scala-2",
    ]
)

def import_compiler_source_repos():
    maven_install(
        name = "scala_compiler",
        artifacts = COMPILER_SOURCES_ARTIFACTS,
        fetch_sources = True,
        repositories = default_maven_server_urls(),
    )

def _compiler_source_repos_impl(_ctx):
    import_compiler_source_repos()

compiler_source_repos = module_extension(
    implementation = _compiler_source_repos_impl,
)
