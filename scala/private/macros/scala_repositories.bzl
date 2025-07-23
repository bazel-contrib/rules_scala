load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@rules_scala_config//:config.bzl", "SCALA_VERSIONS")
load("//:scala_config.bzl", "DEFAULT_SCALA_VERSION")
load(
    "//scala:scala_cross_version.bzl",
    "extract_major_version",
    "extract_minor_version",
    "version_suffix",
)
load(
    "//scala/private:macros/compiler_sources_integrity.bzl",
    "COMPILER_SOURCES",
    "URL_PREFIX",
    "URL_SUFFIX_BY_MAJOR_VERSION",
)

def _dt_patched_compiler_impl(rctx):
    # Need to give the file a .zip extension so rctx.extract knows what type of archive it is
    rctx.symlink(rctx.attr.srcjar, "file.zip")
    rctx.extract(archive = "file.zip")
    rctx.patch(rctx.attr.patch)
    rctx.file("BUILD", content = rctx.attr.build_file_content)

dt_patched_compiler = repository_rule(
    attrs = {
        "patch": attr.label(),
        "srcjar": attr.label(),
        "build_file_content": attr.string(),
    },
    implementation = _dt_patched_compiler_impl,
)
_COMPILER_SOURCE_ALIAS_TEMPLATE = """alias(
    name = "src",
    visibility = ["//visibility:public"],
    actual = select({{{compiler_sources}
    }}),
)
"""

_COMPILER_SOURCES_ENTRY_TEMPLATE = """
        "@rules_scala_config//:scala_version{scala_version_suffix}":
            "@scala_compiler_source{scala_version_suffix}//:src","""

def _compiler_sources_repo_impl(rctx):
    sources = [
        _COMPILER_SOURCES_ENTRY_TEMPLATE.format(
            scala_version_suffix = version_suffix(scala_version),
        )
        for scala_version in SCALA_VERSIONS
    ]
    build_content = _COMPILER_SOURCE_ALIAS_TEMPLATE.format(
        compiler_sources = "".join(sources),
    )
    rctx.file("BUILD", content = build_content, executable = False)

compiler_sources_repo = repository_rule(
    implementation = _compiler_sources_repo_impl,
)

def _get_compiler_srcjar(scala_version, scala_compiler_srcjar):
    if scala_compiler_srcjar:
        return scala_compiler_srcjar

    compiler_srcjar = COMPILER_SOURCES.get(scala_version, None)

    if compiler_srcjar:
        return compiler_srcjar

    # Try to guess what the correct URL will be for scala_version based on its
    # major semver number.
    requested_major_version = scala_version.split(".", 1)[0]
    highest_known_major_version = URL_SUFFIX_BY_MAJOR_VERSION.keys()[-1]
    guessed_suffix = (
        URL_SUFFIX_BY_MAJOR_VERSION.get(requested_major_version, None) or
        URL_SUFFIX_BY_MAJOR_VERSION[highest_known_major_version]
    )
    guessed_compiler_srcjar_url = (
        URL_PREFIX + guessed_suffix.format(version = scala_version)
    )
    no_compiler_source_jar_integrity_error = """
No compiler source jar integrity data exists in rules_scala for Scala version
{version}.

Please supply a compiler_srcjar object in your MODULE.bazel or legacy WORKSPACE
file. For example, replicating the integrity data for Scala version {default}
in MODULE.bazel would look like:

    scala_deps = use_extension(
        "@rules_scala//scala/extensions:deps.bzl",
        "scala_deps",
    )
    scala_deps.scala()
    scala_deps.compiler_srcjar(
        integrity = "{integrity}",
        url = "{url}",
        version = "{default}",
    )

The equivalent legacy WORKSPACE configuration would look like:

    load("@rules_scala//scala:toolchains.bzl", "scala_toolchains")

    scala_toolchains(
        scala_compiler_srcjars = {{
            "{default}": {{
                "integrity": "{integrity}",
                "url": "{url}",
            }},
        }},
    )

Calculate the integrity value using OpenSSL or similar utilities (change the
following URL if it's incorrect for Scala version {version}):

    curl -L {guessed_compiler_srcjar_url} |
        openssl dgst -sha256 -binary | openssl base64

Then add the "sha256-" prefix manually to produce the final "integrity" value.

Also:

- You may replace the single "url" with a list of multiple "urls", or with a
  "label" if a BUILD target exists for the source jar. However, you can use only
  one of "url", "urls", or "label".

- You may omit the "integrity" value, or the alternative "sha256" value.
  However, Bazel will emit a warning about obtaining a "canonical reproducible
  form" by using a specific "integrity" value. You can then add that "integrity"
  value to the compiler_srcjar object (if you trust it).

For more information, see:

- the Subresource Integrity format description at
  https://developer.mozilla.org/docs/Web/Security/Subresource_Integrity
  and the formal spec at https://www.w3.org/TR/sri-2/

- the docstring from the compiler_srcjar tag_class in
  @rules_scala//scala/extensions:deps.bzl

- the docstring from scala_toolchains() in @rules_scala//scala:toolchains.bzl

- the dt_patches/test_dt_patches_user_srcjar/{{MODULE.bazel,WORKSPACE}} files
  in rules_scala for more examples

""".format(
        version = scala_version,
        default = DEFAULT_SCALA_VERSION,
        guessed_compiler_srcjar_url = guessed_compiler_srcjar_url,
        **COMPILER_SOURCES[DEFAULT_SCALA_VERSION]
    )
    fail(no_compiler_source_jar_integrity_error)

def _validate_scalac_srcjar(srcjar):
    count = 0

    if type(srcjar) == "dict":
        for key in ["url", "urls", "label"]:
            if srcjar.get(key):
                count += 1

    if count != 1:
        fail(
            "scala_compiler_srcjar invalid, must be a dict " +
            "with exactly one of \"label\", \"url\" or \"urls\" keys, got: " +
            repr(srcjar),
        )

def dt_patched_compiler_setup(scala_version, scala_compiler_srcjar = None):
    scala_major_version = extract_major_version(scala_version)
    scala_minor_version = extract_minor_version(scala_version)
    patch = Label("//dt_patches:dt_compiler_%s.patch" % scala_major_version)

    minor_version = int(scala_minor_version)

    if scala_major_version == "2.12":
        if minor_version >= 1 and minor_version <= 7:
            patch = Label(
                "//dt_patches:dt_compiler_%s.1.patch" % scala_major_version,
            )
        elif minor_version <= 11:
            patch = Label(
                "//dt_patches:dt_compiler_%s.8.patch" % scala_major_version,
            )
    elif scala_major_version.startswith("3."):
        patch = Label("//dt_patches:dt_compiler_3.patch")

    build_file_content = "\n".join([
        "package(default_visibility = [\"//visibility:public\"])",
        "filegroup(",
        "    name = \"src\",",
        "    srcs=[\"scala/tools/nsc/symtab/SymbolLoaders.scala\"]," if scala_major_version.startswith("2.") else "    srcs=[\"dotty/tools/dotc/core/SymbolLoaders.scala\"],",
        ")",
    ])
    srcjar = _get_compiler_srcjar(scala_version, scala_compiler_srcjar)
    _validate_scalac_srcjar(srcjar)

    if srcjar.get("label"):
        dt_patched_compiler(
            name = "scala_compiler_source" + version_suffix(scala_version),
            build_file_content = build_file_content,
            patch = patch,
            srcjar = srcjar["label"],
        )
    else:
        http_archive(
            name = "scala_compiler_source" + version_suffix(scala_version),
            build_file_content = build_file_content,
            patches = [patch],
            url = srcjar.get("url"),
            urls = srcjar.get("urls"),
            sha256 = srcjar.get("sha256"),
            integrity = srcjar.get("integrity"),
        )

def setup_scala_compiler_sources(srcjars = {}):
    """Generates Scala compiler source repos used internally by rules_scala.

    Args:
        srcjars: optional dictionary of Scala version string to compiler srcjar
            metadata dictionaries containing:
            - exactly one "label", "url", or "urls" key
            - optional "integrity" or "sha256" keys
    """
    for scala_version in SCALA_VERSIONS:
        dt_patched_compiler_setup(scala_version, srcjars.get(scala_version))

    compiler_sources_repo(name = "scala_compiler_sources")

def scala_version_artifact_ids(scala_version):
    result = [
        "io_bazel_rules_scala_scala_compiler",
        "io_bazel_rules_scala_scala_library",
        "io_bazel_rules_scala_scala_parser_combinators",
        "io_bazel_rules_scala_scala_xml",
        "org_scala_lang_modules_scala_collection_compat",
    ]

    if scala_version.startswith("2."):
        result.extend([
            "io_bazel_rules_scala_scala_reflect",
            "org_scalameta_semanticdb_scalac",
        ])

    if scala_version.startswith("2.13.") or scala_version.startswith("3."):
        # Since the Scala 2.13 compiler is included in Scala 3 deps.
        result.extend([
            "io_github_java_diff_utils_java_diff_utils",
            "net_java_dev_jna_jna",
            "org_jline_jline",
        ])

    if scala_version.startswith("3."):
        result.extend([
            "io_bazel_rules_scala_scala_asm",
            "io_bazel_rules_scala_scala_compiler_2",
            "io_bazel_rules_scala_scala_interfaces",
            "io_bazel_rules_scala_scala_library_2",
            "io_bazel_rules_scala_scala_reflect_2",
            "io_bazel_rules_scala_scala_tasty_core",
            "org_jline_jline_native",
            "org_jline_jline_reader",
            "org_jline_jline_terminal",
            "org_jline_jline_terminal_jna",
            "org_jline_jline_terminal_jni",
            "org_scala_sbt_compiler_interface",
            "org_scala_sbt_util_interface",
        ])

    return result
