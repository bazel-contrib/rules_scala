load("@bazel_skylib//rules:run_binary.bzl", "run_binary")
load("@rules_jvm_external//:defs.bzl", "maven_export")
load("//scala/private:rules/scala_doc.bzl", "make_scala_doc_rule", "scaladoc_intransitive_aspect")
load("//scala/private:rules/scala_library.bzl", "scala_library")

DEFAULT_EXCLUDED_WORKSPACES = [
    # Note: we choose to drop the dependency entirely because
    #       we can't be sure which coordinate the user has
    #       chosen for protobuf.
    "com_google_protobuf",
    "protobuf",  # bzlmod module deps are in the form of '@protobuf~<version>'
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
    """Extends `scala_library` to allow maven artifacts to be uploaded. This
    rule is the Scala version of `java_export`. It needs `rules_jvm_external`
    6.9 or later, which a legacy `WORKSPACE` must declare itself.

    This macro can be used as a drop-in replacement for `scala_library`, but
    also generates an implicit `name.publish` target that can be run to publish
    maven artifacts derived from this macro to a maven repository. The publish
    rule understands the following variables (declared using `--define` when
    using `bazel run`):

      * `maven_repo`: A URL for the repo to use. May be "https" or "file".
      * `maven_user`: The user name to use when uploading to the maven repository.
      * `maven_password`: The password to use when uploading to the maven repository.

    This macro also generates a `name-pom` target that creates the `pom.xml` file
    associated with the artifacts. The template used is derived from the (optional)
    `pom_template` argument, and the following substitutions are performed on
    the template file:

      * `{groupId}`: Replaced with the maven coordinates group ID.
      * `{artifactId}`: Replaced with the maven coordinates artifact ID.
      * `{version}`: Replaced by the maven coordinates version.
      * `{type}`: Replaced by the maven coordintes type, if present (defaults to "jar")
      * `{dependencies}`: Replaced by a list of maven dependencies directly relied upon
        by scala_library targets within the artifact.

    The "edges" of the artifact are found by scanning targets that contribute to
    runtime dependencies for the following tags:

      * `maven_coordinates=group:artifact:type:version`: Specifies a dependency of
        this artifact.
      * `maven:compile-only`: Specifies that this dependency should not be listed
        as a dependency of the artifact being generated.

    To skip generation of the javadoc jar, add the `no-javadocs` tag to the target.

    Generated rules:
      * `name`: The artifact's jar, for other rules to depend upon.
      * `name-lib`: The `scala_library` that compiles the sources.
      * `name-javadoc`: A scaladoc jar file (published as javadoc).
      * `name-pom`: The pom.xml file.
      * `name.publish`: To be executed by `bazel run` to publish to a maven repo.

    Args:
      name: A unique name for this target
      maven_coordinates: The maven coordinates for this target.
      pom_template: The template to be used for the pom.xml file.
      deploy_env: A list of labels of java targets to exclude from the generated jar
      visibility: The visibility of the target
      publish_maven_metadata: Whether to publish a maven-metadata.xml
      scala_library_maven_deps: A target that exports the Scala standard
        library with `maven_coordinates` tags, which puts the standard library
        in the pom and removes it from the jar. The default target exports the
        jars of the default Scala toolchain. Give your own target if your
        toolchain sets a different `scala_library_classpath`. Use your own
        target or `None` with `scala_toolchains(scala = False)`, which skips the
        default target. `None` adds no target.
      kwargs: These are passed to [`scala_library`](https://github.com/bazelbuild/rules_scala/blob/master/docs/scala_library.md),
        and so may contain any valid parameter for that rule.
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

        # This is the body of rules_jvm_external's `create_jar`, which accepts
        # only `name`, `inputs` and `out`, so it cannot set `testonly`.
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
