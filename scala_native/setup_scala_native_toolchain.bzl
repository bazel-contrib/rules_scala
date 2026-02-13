"""Scala Native toolchain setup and configuration."""

load(
  "//scala_native:scala_native_toolchain.bzl",
  "scala_native_toolchain",
)

def setup_scala_native_toolchain(
        name = "scala_native_toolchain",
        nscplugin = "@org_scala_native_nscplugin//jar",
        linker = "@org_scala_native_tools//jar",
        test_interface = "@org_scala_native_test_interface//jar",
        junit_runtime = "@org_scala_native_junit_runtime//jar",
        scala_native_version = "0.5.10",
        visibility = ["//visibility:public"]):
    """Creates and registers a Scala Native toolchain.
    
    Args:
        name: Name for the toolchain implementation target.
        nscplugin: Label of the nscplugin JAR.
        linker: Label of the linker JAR.
        test_interface: Label of the test interface JAR.
        junit_runtime: Label of the JUnit runtime JAR.
        scala_native_version: Version of Scala Native.
        visibility: Visibility for the toolchain.
    """
    scala_native_toolchain(
        name = name,
        nscplugin = nscplugin,
        # Default runtime libraries are fixed for now but could be overrideable
        scalalib = "@org_scala_native_scalalib//jar",
        nativelib = "@org_scala_native_nativelib//jar",
        javalib = "@org_scala_native_javalib//jar",
        auxlib = "@org_scala_native_auxlib//jar",
        linker = linker,
        test_interface = test_interface,
        junit_runtime = junit_runtime,
        scala_native_version = scala_native_version,
        visibility = visibility,
    )
    
    native.toolchain(
        name = name + "_toolchain",
        toolchain = ":" + name,
        toolchain_type = "//scala_native:toolchain_type",
        visibility = visibility,
    )
