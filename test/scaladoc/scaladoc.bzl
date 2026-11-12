load("@rules_java//java/common:java_info.bzl", "JavaInfo")
load("//scala:scala.bzl", "ScaladocAspectInfo", "make_scala_doc_rule", "scaladoc_intransitive_aspect")
load("//test/expect_build_failure:expect_analysis_failure.bzl", "make_expect_analysis_failure_test")

scala_doc_intransitive = make_scala_doc_rule(scaladoc_intransitive_aspect)  #Only scaladoc specified deps

def _old_fields_aspect_impl(target, ctx):
    return [ScaladocAspectInfo(
        src_files = depset([f for f in ctx.rule.files.srcs if f.extension == "scala"]),
        compile_jars = target[JavaInfo].transitive_compile_time_jars,
        macro_classpath = depset(),
        plugins = depset(),
    )]

# A custom aspect that sets only the fields that `ScaladocAspectInfo` had first.
_old_fields_aspect = aspect(
    implementation = _old_fields_aspect_impl,
    required_aspect_providers = [[JavaInfo]],
)

scala_doc_old_fields = make_scala_doc_rule(_old_fields_aspect)

expect_analysis_failure_without_doc_classpath_test = make_expect_analysis_failure_test({
    "//command_line_option:extra_toolchains": ["//test/toolchains/scala_doc_classpath_missing:toolchain"],
})

expect_analysis_failure_with_scaladoc_version_mismatch_test = make_expect_analysis_failure_test({
    "//command_line_option:extra_toolchains": ["//test/toolchains/scala_doc_version_mismatch:toolchain"],
})

def _site_dir_impl(ctx):
    out = ctx.actions.declare_directory(ctx.attr.name)
    ctx.actions.run_shell(
        outputs = [out],
        command = "mkdir \"$1/_docs\" && printf -- '---\\ntitle: Tree\\n---\\n' > \"$1/_docs/tree.md\"",
        arguments = [out.path],
    )
    return [DefaultInfo(files = depset([out]))]

# A static site as one directory output, as from a site generator.
site_dir = rule(implementation = _site_dir_impl)
