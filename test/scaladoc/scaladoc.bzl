load("@bazel_skylib//lib:unittest.bzl", "analysistest", "asserts")
load("@rules_java//java/common:java_info.bzl", "JavaInfo")
load("//scala:scala.bzl", "ScaladocAspectInfo", "make_scala_doc_rule", "scaladoc_intransitive_aspect")

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

def _without_doc_classpath_failure_impl(ctx):
    env = analysistest.begin(ctx)
    asserts.expect_failure(env, "Scala 3 `scala_doc` needs `scala_doc_classpath` on the Scala toolchain.")
    return analysistest.end(env)

# Asserts the error of Scala 3 `scala_doc` under the toolchain
# `:scala3_without_doc_classpath`.
scaladoc_without_doc_classpath_failure_test = analysistest.make(
    _without_doc_classpath_failure_impl,
    expect_failure = True,
    config_settings = {
        "//command_line_option:extra_toolchains": [str(Label(":scala3_without_doc_classpath"))],
    },
)
