load("@bazel_skylib//rules:run_binary.bzl", "run_binary")
load("@rules_jvm_external//:defs.bzl", "maven_export")
load("//scala/private:rules/scala_doc.bzl", "make_scala_doc_rule", "scaladoc_intransitive_aspect")
load("//scala/private:rules/scala_library.bzl", "scala_library")

# By default, the jar omits the protobuf classes. Protobuf has many Maven
# artifacts, such as `protobuf-java` and `protobuf-javalite`, so the user
# selects one and adds it as a dependency.
DEFAULT_EXCLUDED_WORKSPACES = [
    "com_google_protobuf",  # The repo name with `WORKSPACE`.
    "protobuf",  # The module name with Bzlmod.
]

scala_doc = make_scala_doc_rule(aspect = scaladoc_intransitive_aspect)

def scala_export(
        name,
        maven_coordinates,
        deploy_env = [],
        excluded_workspaces = {name: None for name in DEFAULT_EXCLUDED_WORKSPACES},
        exclusions = {},
        pom_template = None,
        visibility = None,
        tags = [],
        testonly = None,
        publish_maven_metadata = False,
        scala_library_maven_deps = Label("@rules_scala_toolchains//scala:scala_library_maven_deps"),
        **kwargs):
    """Builds a `scala_library` and the files to publish it to a Maven
    repository. This macro is the Scala version of `java_export` from
    `rules_jvm_external`. It needs `rules_jvm_external` 6.9 or later. A legacy
    `WORKSPACE` must declare it.

    Other targets can depend on `name` to get its jar. To publish the
    files, use `bazel run` on `name.publish` with these `--define` values:

      * `maven_repo`: The URL of the Maven repository, with `https` or `file`.
      * `maven_user`: The user name for the Maven repository.
      * `maven_password`: The password for the Maven repository.

    The `name-pom` target makes the `pom.xml` file from `pom_template`, or
    from the default template. It replaces these values in the template:

      * `{groupId}`: The group ID from `maven_coordinates`.
      * `{artifactId}`: The artifact ID from `maven_coordinates`.
      * `{version}`: The version from `maven_coordinates`.
      * `{type}`: The type from `maven_coordinates`. The default is "jar".
      * `{dependencies}`: The direct Maven dependencies of the `scala_library`
        targets in the jar.

    The macro finds the Maven dependencies from these tags on the runtime
    dependencies:

      * `maven_coordinates=group:artifact:type:version`: The pom lists this
        target, and the jar omits its classes.
      * `maven:compile-only`: The pom omits this target, and the jar omits its
        classes.

    The `no-javadocs` tag skips the Scaladoc jar.

    Generated targets:
      * `name`: The jar to publish. Other targets can depend on it.
      * `name-lib`: The `scala_library` that compiles the sources.
      * `name-javadoc`: The Scaladoc jar, which is published as the javadoc jar.
      * `name-pom`: The `pom.xml` file.
      * `name.publish`: Publishes the files with `bazel run`.

    Args:
      name: The name of the target.
      maven_coordinates: The Maven coordinates of the jar, for example
        `group:artifact:version`.
      pom_template: The template for the `pom.xml` file.
      deploy_env: The library targets to remove from the jar, together with
        their runtime dependencies.
      visibility: The visibility of the targets.
      publish_maven_metadata: If `True`, also publish a `maven-metadata.xml`
        file.
      scala_library_maven_deps: A target that exports the Scala standard
        library jars with `maven_coordinates` tags. Thus the pom lists the
        standard library, and the jar omits it. The default target exports the
        jars of the default Scala toolchain. Give your own target if your
        toolchain sets a different `scala_library_classpath`. With
        `scala_toolchains(scala = False)`, the default target is missing, so
        give your own target or `None`. Set `None` to skip this export.
      kwargs: Arguments for [`scala_library`](https://github.com/bazelbuild/rules_scala/blob/master/docs/scala_library.md).
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
        scala_doc(
            name = scaladocs_name,
            deps = [":" + lib_name],
            scalacopts = kwargs.get("scalacopts", []),
            tags = tags,
            testonly = testonly,
            visibility = visibility,
        )

        # This does the same as `create_jar` from `rules_jvm_external`, and also
        # sets `tags`, `testonly` and `visibility`. `create_jar` accepts only
        # `name`, `inputs` and `out`.
        javadoc_jar_name = name + "-javadoc"
        javadoc_jar = name + "-javadoc.jar"
        javadoc_inputs = [":" + scaladocs_name] + doc_resources
        run_binary(
            name = javadoc_jar_name,
            srcs = javadoc_inputs,
            outs = [javadoc_jar],
            tool = "@rules_jvm_external//private/tools/java/com/github/bazelbuild/rules_jvm_external/jar:CreateJar",
            args = ["$(location %s)" % javadoc_jar] + ["$(location %s)" % i for i in javadoc_inputs],
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
