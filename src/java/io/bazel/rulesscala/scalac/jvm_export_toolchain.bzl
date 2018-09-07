load(
    "@io_bazel_rules_scala//scala:providers.bzl",
    _ScalacProvider = "ScalacProvider")

def _files_of(deps):
  files = []
  for dep in deps:
    files.append(dep[JavaInfo].transitive_compile_time_jars)
  return depset(transitive = files)

def _export_scalac_repositories_from_toolchain_to_jvm_impl(ctx):
  default_repl_classpath_deps = ctx.toolchains[
      '@io_bazel_rules_scala//scala:toolchain_type'].scalac_provider_attr[
          _ScalacProvider].default_repl_classpath
  default_repl_classpath_files = _files_of(
      default_repl_classpath_deps).to_list()
  java_common_provider = java_common.create_provider(
      use_ijar = False,
      compile_time_jars = default_repl_classpath_files,
      runtime_jars = default_repl_classpath_files,
  )
  return [java_common_provider]

export_scalac_repositories_from_toolchain_to_jvm = rule(
    _export_scalac_repositories_from_toolchain_to_jvm_impl,
    toolchains = ['@io_bazel_rules_scala//scala:toolchain_type'])
