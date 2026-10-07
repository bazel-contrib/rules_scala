load(
    "@rules_scala//scala:scala_cross_version.bzl",
    "default_maven_server_urls",
)
load(
    "@rules_scala//scala:scala_maven_import_external.bzl",
    _scala_maven_import_external = "scala_maven_import_external",
)
load(
    "@rules_scala//scala:toolchains_repo.bzl",
    "scala_toolchains_repo",
)
load("@rules_scala//third_party/repositories:repositories.bzl", "repositories")
load(
    "@rules_scala//twitter_scrooge/toolchain:toolchain.bzl",
    "twitter_scrooge_artifact_ids",
)
load("@rules_scala_config//:config.bzl", "SCALA_VERSION")

def _import_external(id, artifact, sha256, deps = [], runtime_deps = []):
    _scala_maven_import_external(
        name = id,
        generated_rule_name = id,
        artifact = artifact,
        artifact_sha256 = sha256,
        licenses = ["notice"],
        server_urls = default_maven_server_urls(),
        deps = deps,
        runtime_deps = runtime_deps,
        testonly_ = False,
        fetch_sources = False,
    )

def scrooge_repositories(version = None):
    use_custom_toolchain_deps = False

    if version == "18.6.0":
        use_custom_toolchain_deps = True
        _import_external(
            id = "io_bazel_rules_scala_scrooge_core",
            artifact = "com.twitter:scrooge-core_2.12:18.6.0",
            sha256 = "02a6d7cf9fe8d872dfabd20298e4315d677748708e153d8b464fd5abac9a7430",
        )
        _import_external(
            id = "io_bazel_rules_scala_scrooge_generator",
            artifact = "com.twitter:scrooge-generator_2.12:18.6.0",
            sha256 = "e7d5da1e3f0e494d3c81a26f44f3e3dc92d7efd757133de8c71758646fd5a833",
            runtime_deps = [
                "@io_bazel_rules_scala_guava",
                "@io_bazel_rules_scala_mustache",
                "@io_bazel_rules_scala_scopt",
            ],
        )
        _import_external(
            id = "io_bazel_rules_scala_util_core",
            artifact = "com.twitter:util-core_2.12:18.6.0",
            sha256 = "65bb92e70f95cbbfc640e54a5823a16154eac1a2631dc0211347e085aaa6ed0b",
        )
        _import_external(
            id = "io_bazel_rules_scala_util_logging",
            artifact = "com.twitter:util-logging_2.12:18.6.0",
            sha256 = "c0cba01705e9321b3444adcd4a9ce27c2acefd27e14c13b5aec2c318ce1b4fdf",
        )

    elif version == "21.2.0":
        use_custom_toolchain_deps = True
        _import_external(
            id = "io_bazel_rules_scala_scrooge_core",
            artifact = "com.twitter:scrooge-core_2.12:21.2.0",
            sha256 = "1178f6cef63c9ad9e787ee7dbb26008d2a8cec9afee7629d0037c534d5b5d575",
        )
        _import_external(
            id = "io_bazel_rules_scala_scrooge_generator",
            artifact = "com.twitter:scrooge-generator_2.12:21.2.0",
            sha256 = "ac5afecfd742ce07cf127b253df20ebf265d75d02d5f38bd8c683da194780862",
            runtime_deps = [
                "@io_bazel_rules_scala_guava",
                "@io_bazel_rules_scala_mustache",
                "@io_bazel_rules_scala_scopt",
            ],
        )
        _import_external(
            id = "io_bazel_rules_scala_util_core",
            artifact = "com.twitter:util-core_2.12:21.2.0",
            sha256 = "5d4ed75a26a3a2cc7fdc1dbeb29878a70024a8b7864287ed1e182dbca9c775a5",
        )
        _import_external(
            id = "io_bazel_rules_scala_util_logging",
            artifact = "com.twitter:util-logging_2.12:21.2.0",
            sha256 = "6110ea70a1ea65c477cec72b7a2ce2ec92427e081ff9366272cb7c3bcadf69a9",
        )

    toolchain_deps = {} if use_custom_toolchain_deps == False else {
        dep: "@io_bazel_rules_scala_%s" % dep
        for dep in [
            "scrooge_core",
            "scrooge_generator",
            "util_core",
            "util_logging",
        ]
    }

    repositories(
        scala_version = SCALA_VERSION,
        for_artifact_ids = twitter_scrooge_artifact_ids(**toolchain_deps),
        maven_servers = default_maven_server_urls(),
        fetch_sources = False,
    )

    scala_toolchains_repo(
        name = "twitter_scrooge_test_toolchain",
        scala = False,
        twitter_scrooge = True,
        twitter_scrooge_deps = toolchain_deps,
    )

_settings = tag_class(
    attrs = {
        "version": attr.string(mandatory = True),
    },
)

def _scrooge_repositories_ext_impl(module_ctx):
    settings = module_ctx.modules[0].tags.settings
    scrooge_repositories(settings[0].version if len(settings) != 0 else None)

scrooge_repositories_ext = module_extension(
    implementation = _scrooge_repositories_ext_impl,
    tag_classes = {
        "settings": _settings,
    },
)
