"""Scaladoc support"""

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@rules_java//java/common:java_info.bzl", "JavaInfo")
load("//scala:providers.bzl", "ScalaInfo")
load("//scala:scala_cross_version.bzl", "scala_version_transition", "toolchain_transition_attr")
load("//scala/private:common.bzl", "collect_plugin_paths")
load(
    "//scala/private/toolchain_deps:toolchain_deps.bzl",
    "find_deps_info_on",
    "find_deps_info_on_if_present",
)

_SCALA_TOOLCHAIN = Label("//scala:toolchain_type")

ScaladocAspectInfo = provider(fields = [
    "src_files",  #depset[File]
    "class_jars",  #depset[File], the full jars that Scala 3 Scaladoc reads TASTy from
    "compile_jars",  #depset[File]
    "macro_classpath",  #depset[File]
    "plugins",  #depset[Target]
    "scala_versions",  #depset[str], the Scala versions of the Scala targets
])

def _scaladoc_intransitive_aspect_impl(target, ctx):
    """Build scaladocs only for the provided targets."""
    return _scaladoc_aspect_impl(target, ctx, transitive = False)

def _scaladoc_aspect_impl(target, ctx, transitive = True):
    """Collect sources, jars and Scala versions from JavaInfo-returning deps."""

    src_files = depset()
    class_jars = depset()
    plugins = depset()
    compile_jars = depset()
    scala_versions = []
    toolchain = ctx.toolchains[_SCALA_TOOLCHAIN]
    if ScalaInfo in target and toolchain:
        scala_versions.append(toolchain.scala_version)
    scala3 = scala_versions and scala_versions[0].startswith("3.")

    # We really only care about visited targets with srcs, so only look at those.
    if hasattr(ctx.rule.attr, "srcs"):
        # Collect only Java and Scala sources enumerated in visited targets, including src_files in deps.
        src_files = depset([file for file in ctx.rule.files.srcs if file.extension.lower() in ["java", "scala"]])

        compile_jars = target[JavaInfo].transitive_compile_time_jars
        # Only Scala 3 writes TASTy.
        if scala3:
            class_jars = depset([output.class_jar for output in target[JavaInfo].java_outputs])

        if hasattr(ctx.rule.attr, "plugins"):
            plugins = depset(ctx.rule.attr.plugins)

    macro_classpath = []

    for dependency in getattr(ctx.rule.attr, "deps", []):
        if ScalaInfo in dependency and dependency[ScalaInfo].contains_macros:
            macro_classpath.append(dependency[JavaInfo].transitive_runtime_jars)

    # Sometimes we only want to generate scaladocs for a single target and not all of its
    # dependencies
    transitive_srcs = []
    transitive_class_jars = []
    transitive_plugins = []
    transitive_scala_versions = []

    if transitive:
        for dep in ctx.rule.attr.deps:
            if ScaladocAspectInfo in dep:
                aspec_info = dep[ScaladocAspectInfo]
                transitive_srcs.append(aspec_info.src_files)
                transitive_class_jars.append(aspec_info.class_jars)
                transitive_plugins.append(aspec_info.plugins)
                transitive_scala_versions.append(aspec_info.scala_versions)

    return [ScaladocAspectInfo(
        src_files = depset(transitive = [src_files] + transitive_srcs),
        class_jars = depset(transitive = [class_jars] + transitive_class_jars),
        compile_jars = depset(transitive = [compile_jars]),
        macro_classpath = depset(transitive = macro_classpath),
        plugins = depset(transitive = [plugins] + transitive_plugins),
        scala_versions = depset(scala_versions, transitive = transitive_scala_versions),
    )]

_scaladoc_transitive_aspect = aspect(
    implementation = _scaladoc_aspect_impl,
    attr_aspects = ["deps"],
    required_aspect_providers = [
        [JavaInfo],
    ],
    toolchains = [config_common.toolchain_type(_SCALA_TOOLCHAIN, mandatory = False)],
)

scaladoc_intransitive_aspect = aspect(
    implementation = _scaladoc_intransitive_aspect_impl,
    attr_aspects = ["deps"],
    required_aspect_providers = [
        [JavaInfo],
    ],
    toolchains = [config_common.toolchain_type(_SCALA_TOOLCHAIN, mandatory = False)],
)

def _jar_version(deps, artifact):
    # Maven jar names are `<artifact>-<version>.jar`, sometimes with a prefix
    # such as `processed_`.
    for dep in deps:
        for jar in dep[JavaInfo].transitive_runtime_jars.to_list():
            i = jar.basename.find(artifact + "-")
            if i == 0 or (i > 0 and jar.basename[i - 1] == "_"):
                return jar.basename[i + len(artifact) + 1:].removesuffix(".jar")
    return None

def _site_files(ctx):
    """Returns (path under `site_root`, File) for each file of `site_srcs`."""
    repo = "../%s/" % ctx.label.workspace_name if ctx.label.workspace_name else ""
    root = paths.normalize(paths.join(repo + ctx.label.package, ctx.attr.site_root))
    prefix = "" if root == "." else root + "/"
    result = []
    for file in ctx.files.site_srcs:
        path = file.short_path[len(prefix):]

        # With an empty prefix, files of other repositories start with `../`.
        if not file.short_path.startswith(prefix) or path.startswith("../"):
            fail("%s: `site_srcs` file %s is not under `site_root` %s." % (ctx.label, file.short_path, root))
        result.append((path, file))
    return result

def _scala3_doc(ctx, output_path, compile_jars):
    """Runs Scala 3 Scaladoc, which reads TASTy from compiled classes."""
    doc_classpath = find_deps_info_on_if_present(ctx, _SCALA_TOOLCHAIN, "scala_doc_classpath")
    if not doc_classpath or not doc_classpath.deps:
        fail("%s: Scala 3 `scala_doc` needs `scala_doc_classpath` on the Scala toolchain. Enable it with `scala_deps.scaladoc()` or `scala_toolchains(scaladoc = True)`." % ctx.label)
    compile_classpath = find_deps_info_on(ctx, _SCALA_TOOLCHAIN, "scala_compile_classpath")
    scaladoc_version = _jar_version(doc_classpath.deps, "scaladoc_3")
    compiler_version = _jar_version(compile_classpath.deps, "scala3-compiler_3")
    if scaladoc_version and compiler_version and scaladoc_version != compiler_version:
        fail("%s: Scaladoc %s runs only with Scala compiler %s, and the Scala toolchain gives compiler %s. Use the same version for both." % (
            ctx.label,
            scaladoc_version,
            scaladoc_version,
            compiler_version,
        ))

    infos = [dep[ScaladocAspectInfo] for dep in ctx.attr.deps]
    if not all([hasattr(info, "class_jars") for info in infos]):
        fail("%s: Scala 3 `scala_doc` needs `class_jars` in `ScaladocAspectInfo`. Set it in the aspect of this rule." % ctx.label)
    class_jars = depset(transitive = [info.class_jars for info in infos])

    # The runner reads one argument on each line of the params file.
    for opt in ctx.attr.scalacopts:
        if "\n" in opt or "\r" in opt:
            fail("%s: each `scalacopts` value of Scala 3 `scala_doc` must be one line: %r" % (ctx.label, opt))

    args = ctx.actions.args()
    args.set_param_file_format("multiline")
    args.use_param_file(param_file_arg = "@%s", use_always = True)
    args.add_all(class_jars, format_each = "--tasty_jar=%s")
    for path, file in _site_files(ctx):
        args.add("--site_file=" + path)
        args.add(file)
    args.add("-project", ctx.label.name)
    args.add_all(ctx.attr.scalacopts)
    args.add("-d")
    args.add_all([output_path], expand_directories = False)
    args.add_joined("-classpath", compile_jars, join_with = ctx.configuration.host_path_separator)

    ctx.actions.run(
        inputs = depset(ctx.files.site_srcs, transitive = [compile_jars, class_jars]),
        outputs = [output_path],
        executable = ctx.executable._scala3_scaladoc,
        mnemonic = "ScalaDoc",
        progress_message = "scaladoc {}".format(ctx.label),
        arguments = [args],
    )

def _scala_doc_impl(ctx):
    # scaladoc warns if you don't have the output directory already created, which is annoying.
    output_path = ctx.actions.declare_directory("{}.html".format(ctx.attr.name))

    compile_jars = depset(transitive = [dep[ScaladocAspectInfo].compile_jars for dep in ctx.attr.deps])

    # Scala 2 Scaladoc compiles the sources, and Scala 3 syntax makes it fail.
    scala_version = ctx.toolchains[_SCALA_TOOLCHAIN].scala_version
    scala3 = scala_version.startswith("3.")
    # A custom aspect can make `ScaladocAspectInfo` without the newer fields.
    scala_versions = depset(transitive = [getattr(dep[ScaladocAspectInfo], "scala_versions", depset()) for dep in ctx.attr.deps])
    for dep_version in scala_versions.to_list():
        if dep_version.startswith("3.") and not scala3:
            fail("%s: a dependency uses Scala %s, and this target uses Scala %s. Set `scala_version = \"%s\"` on this target." % (
                ctx.label,
                dep_version,
                scala_version,
                dep_version,
            ))

    if scala3:
        _scala3_doc(ctx, output_path, compile_jars)
        return [DefaultInfo(files = depset(direct = [output_path]))]

    if ctx.files.site_srcs:
        fail("%s: `site_srcs` works only with Scala 3. This target uses Scala %s." % (ctx.label, scala_version))

    # Collect all source files to pass to scaladoc by way of an aspect.
    src_files = depset(transitive = [dep[ScaladocAspectInfo].src_files for dep in ctx.attr.deps])

    # See the documentation for `collect_jars` in `scala/private/common.bzl` to understand why this is prepended to the
    # classpath
    macro_classpath = depset(transitive = [dep[ScaladocAspectInfo].macro_classpath for dep in ctx.attr.deps])

    # Get the 'real' paths to the plugin jars.
    plugins = collect_plugin_paths(depset(transitive = [dep[ScaladocAspectInfo].plugins for dep in ctx.attr.deps]).to_list())

    # Construct the full classpath depset since we need to add compiler plugins too.
    classpath = depset(transitive = [macro_classpath, plugins, compile_jars])

    # Construct scaladoc args, which also include scalac args.
    # See `scaladoc -help` for more information.
    args = ctx.actions.args()
    args.set_param_file_format("multiline")
    args.use_param_file(param_file_arg = "@%s", use_always = True)
    args.add("-usejavacp")
    args.add("-nowarn")  # turn off warnings for now since they can obscure actual errors for large scala_doc targets
    args.add_all(ctx.attr.scalacopts)
    # output_path is a directory, and Args#add rejects those because they may expand to
    # multiple values. add_all with expand_directories = False passes it as one mapped path.
    args.add("-d")
    args.add_all([output_path], expand_directories = False)
    args.add_all(plugins, format_each = "-Xplugin:%s")
    args.add_joined("-classpath", classpath, join_with = ctx.configuration.host_path_separator)
    args.add_all(src_files)

    # Run the scaladoc tool!
    ctx.actions.run(
        inputs = depset(transitive = [src_files, classpath]),
        outputs = [output_path],
        executable = ctx.attr._scaladoc.files_to_run.executable,
        mnemonic = "ScalaDoc",
        progress_message = "scaladoc {}".format(ctx.label),
        arguments = [args],
    )

    return [DefaultInfo(files = depset(direct = [output_path]))]

def make_scala_doc_rule(aspect = _scaladoc_transitive_aspect):
    return rule(
        attrs = {
            "deps": attr.label_list(
                aspects = [aspect],
                providers = [JavaInfo],
            ),
            "scalacopts": attr.string_list(),
            "site_srcs": attr.label_list(allow_files = True),
            "site_root": attr.string(),
            "_scaladoc": attr.label(
                cfg = "exec",
                executable = True,
                default = "//src/scala/io/bazel/rules_scala/scaladoc_support:scaladoc_generator",
            ),
            "_scala3_scaladoc": attr.label(
                cfg = "exec",
                executable = True,
                default = "//src/java/io/bazel/rulesscala/scaladoc:runner",
            ),
        } | toolchain_transition_attr,
        doc = "Generate Scaladoc HTML documentation for source files in from the given dependencies.",
        toolchains = [_SCALA_TOOLCHAIN],
        cfg = scala_version_transition,
        implementation = _scala_doc_impl,
    )
