"""Scala Native toolchain definition for Bazel."""

load(
  "@rules_java//java:defs.bzl",
  "JavaInfo",
)

def _scala_native_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        nscplugin = ctx.attr.nscplugin,
        scalalib = ctx.attr.scalalib,
        nativelib = ctx.attr.nativelib,
        javalib = ctx.attr.javalib,
        auxlib = ctx.attr.auxlib,
        linker = ctx.attr.linker,
        linker_binary = ctx.attr.linker_binary,
        test_interface = ctx.attr.test_interface,
        junit_runtime = ctx.attr.junit_runtime,
        scala_native_version = ctx.attr.scala_native_version,
    )
    return [toolchain_info]

scala_native_toolchain = rule(
    implementation = _scala_native_toolchain_impl,
    doc = "Defines a Scala Native toolchain providing the nscplugin compiler plugin.",
    attrs = {
        "nscplugin": attr.label(
            mandatory = True,
            providers = [JavaInfo],
            doc = "The nscplugin compiler plugin JAR target",
        ),
        "scalalib": attr.label(
            mandatory = True,
            providers = [JavaInfo],
            doc = "The Scala Native runtime library",
        ),
        "nativelib": attr.label(
            mandatory = True,
            providers = [JavaInfo],
            doc = "The Scala Native core library (unsafe, runtime, etc.)",
        ),
        "javalib": attr.label(
            mandatory = True,
            providers = [JavaInfo],
            doc = "The Scala Native Java compatibility library",
        ),
        "auxlib": attr.label(
            mandatory = True,
            providers = [JavaInfo],
            doc = "The Scala Native auxiliary library",
        ),
        "linker": attr.label(
            mandatory = True,
            providers = [JavaInfo],
            doc = "The Scala Native tools (linker)",
        ),
        "linker_binary": attr.label(
            mandatory = True,
            executable = True,
            cfg = "exec",
            doc = "The Scala Native linker executable binary",
        ),
        "test_interface": attr.label(
            mandatory = True,
            providers = [JavaInfo],
            doc = "The Scala Native test interface",
        ),
        "junit_runtime": attr.label(
            mandatory = True,
            providers = [JavaInfo],
            doc = "The Scala Native JUnit runtime",
        ),
        "scala_native_version": attr.string(
            default = "0.5.10",
            doc = "The Scala Native version",
        ),
    },
    provides = [platform_common.ToolchainInfo],
)
