load("@rules_jvm_external//:defs.bzl", "maven_export")
load("//scala/private:rules/scala_doc.bzl", "make_scala_doc_rule", "scaladoc_intransitive_aspect")
load("//scala/private:rules/scala_library.bzl", "scala_library")

# A copy of the private `DEFAULT_EXCLUDED_WORKSPACES` of `java_export`. By
# default, the jar omits the protobuf classes, and the user selects a Maven
# artifact for them, such as `protobuf-java` or `protobuf-javalite`.
_DEFAULT_EXCLUDED_WORKSPACES = [
    "com_google_protobuf",  # The repo name with `WORKSPACE`.
    "protobuf",  # The module name with Bzlmod.
]

_scala_doc = make_scala_doc_rule(aspect = scaladoc_intransitive_aspect)

def _javadoc_jar_impl(ctx):
    out = ctx.actions.declare_file(ctx.label.name + ".jar")
    args = ctx.actions.args()
    args.add(out)
    args.add_all(ctx.files.srcs, expand_directories = False)
    ctx.actions.run(
        executable = ctx.executable._create_jar,
        arguments = [args],
        inputs = ctx.files.srcs,
        outputs = [out],
        mnemonic = "CreateJar",
        use_default_shell_env = True,
    )
    return [DefaultInfo(files = depset([out]))]

# Runs the tool of the `create_jar` macro from `rules_jvm_external`. The macro
# takes one file for each label, and `java_export` takes all files of `doc_resources`.
_javadoc_jar = rule(
    implementation = _javadoc_jar_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "_create_jar": attr.label(
            default = Label("@rules_jvm_external//private/tools/java/com/github/bazelbuild/rules_jvm_external/jar:CreateJar"),
            executable = True,
            cfg = "exec",
        ),
    },
)

def scala_export(
        name,
        maven_coordinates,
        deploy_env = [],
        excluded_workspaces = {name: None for name in _DEFAULT_EXCLUDED_WORKSPACES},
        exclusions = {},
        pom_template = None,
        visibility = None,
        tags = [],
        testonly = None,
        publish_maven_metadata = False,
        scala_library_maven_deps = Label("@rules_scala_toolchains//scala:scala_library_maven_deps"),
        **kwargs):
    """Builds a `scala_library` and the files to publish it to a Maven repository.

    This macro is the Scala version of `java_export` from
    `rules_jvm_external`. It needs `rules_jvm_external` 6.9 or later. In a
    legacy `WORKSPACE`, declare `rules_jvm_external` before you call
    `protobuf_deps()`. Otherwise, `protobuf_deps()` declares an older version.

    The publish settings, the `pom_template` values, the Maven tags and the
    arguments `deploy_env`, `excluded_workspaces`, `exclusions`,
    `pom_template`, `classifier_artifacts`, `doc_resources` and
    `publish_maven_metadata` work as in
    [`java_export`](https://github.com/bazel-contrib/rules_jvm_external/blob/6.9/docs/api.md#java_export).
    The javadoc jar contains the Scaladoc of the sources, and it replaces a
    `javadoc` entry of `classifier_artifacts`. The `no-javadocs` tag skips the
    Scaladoc. With Scala 3, the Scaladoc needs `scala_toolchains(scaladoc = True)`
    or `scala_deps.scaladoc()`.

    The main generated targets:
      * `name`: The jar to publish. Other targets can depend on it.
      * `name-lib`: The `scala_library` that compiles the sources.
      * `name-scaladocs-html`: The Scaladoc HTML.
      * `name-javadoc`: The Scaladoc jar, which is published as the javadoc jar.
      * `name-pom`: The `pom.xml` file.
      * `name.publish`: Publishes the files with `bazel run`.

    Args:
      name: The name of the target.
      maven_coordinates: The Maven coordinates of the jar, for example
        `group:artifact:version`.
      scala_library_maven_deps: A target that exports the Scala standard
        library jars with `maven_coordinates` tags. Thus the pom lists the
        standard library, and the jar omits it. The default target exports the
        jars of the default Scala toolchain. Give your own target if your
        toolchain sets a different `scala_library_classpath`. With
        `scala_toolchains(scala = False)`, the default target is missing, so
        give your own target or `None`. Set `None` to skip this export.
      kwargs: The other arguments are for [`scala_library`](https://github.com/bazel-contrib/rules_scala/blob/master/docs/scala_library.md).
    """
    maven_coordinates_tags = ["maven_coordinates=%s" % maven_coordinates]
    lib_name = "%s-lib" % name

    doc_resources = kwargs.pop("doc_resources", [])
    classifier_artifacts = dict(kwargs.pop("classifier_artifacts", {}))

    exports = kwargs.pop("exports", [])
    if scala_library_maven_deps:
        exports = exports + [scala_library_maven_deps]

    scala_library(
        name = lib_name,
        exports = exports,
        tags = tags + maven_coordinates_tags,
        testonly = testonly,
        visibility = visibility,
        **kwargs
    )

    if "no-javadocs" not in tags:
        scaladocs_name = name + "-scaladocs-html"
        _scala_doc(
            name = scaladocs_name,
            deps = [":" + lib_name],
            scalacopts = kwargs.get("scalacopts", []),
            scala_version = kwargs.get("scala_version"),
            tags = tags,
            testonly = testonly,
            visibility = visibility,
        )

        javadoc_jar_name = name + "-javadoc"
        _javadoc_jar(
            name = javadoc_jar_name,
            srcs = [":" + scaladocs_name] + doc_resources,
            tags = tags,
            testonly = testonly,
            visibility = visibility,
        )
        classifier_artifacts["javadoc"] = javadoc_jar_name

    maven_export(
        name = name,
        maven_coordinates = maven_coordinates,
        classifier_artifacts = classifier_artifacts,
        lib_name = lib_name,
        deploy_env = deploy_env,
        excluded_workspaces = excluded_workspaces,
        exclusions = exclusions,
        pom_template = pom_template,
        visibility = visibility,
        tags = tags + ["no-javadocs"],
        testonly = testonly,
        publish_maven_metadata = publish_maven_metadata,
    )
