"""Definitions for Scala Native toolchain artifacts."""

load("//scala:scala_cross_version.bzl", "extract_major_version")

# The set of Scala major versions that have Scala Native artifact definitions
# in their corresponding third_party/repositories/scala_*.bzl file.
# When adding Scala Native support for a new major version, add it here AND
# add the artifact entries to the corresponding scala_*.bzl file.
SCALA_NATIVE_SUPPORTED_MAJOR_VERSIONS = [
  "3.8",  # The first major version without any dependencies on Scala 2
]

def scala_native_artifact_ids(scala_version):
  """Returns a list of Maven artifact IDs for Scala Native.

  Only returns artifact IDs for Scala versions whose major version is listed
  in SCALA_NATIVE_SUPPORTED_MAJOR_VERSIONS. For unsupported versions, returns
  an empty list, which causes scala_toolchains() to skip fetching SN artifacts.

  Args:
    scala_version: The Scala version string (e.g. "3.3.7").

  Returns:
    A list of artifact ID strings, or an empty list if unsupported.
  """
  major = extract_major_version(scala_version)
  if major in SCALA_NATIVE_SUPPORTED_MAJOR_VERSIONS:
    return [
        "io_bazel_rules_scala_junit_junit",
        "org_scala_native_auxlib",
        "org_scala_native_clib",
        "org_scala_native_javalib",
        "org_scala_native_junit_runtime",
        "org_scala_native_nativelib",
        "org_scala_native_nir",
        "org_scala_native_nscplugin",
        "org_scala_native_posixlib",
        "org_scala_native_scalalib",
        "org_scala_native_test_interface",
        "org_scala_native_tools",
        "org_scala_native_util",
        "org_scala_sbt_compiler_interface",
        "org_scala_sbt_util_interface",
    ]
  return []
