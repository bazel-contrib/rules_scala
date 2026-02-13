load("//scala:scala.bzl", "scala_binary")

# A single native_linker target that uses the alias (unsuffixed) repos.
# The alias repos always point to the default SCALA_VERSION's artifacts,
# which is set up by the repositories() function in
# third_party/repositories/repositories.bzl.
scala_binary(
    name = "native_linker",
    srcs = ["NativeLinker.scala"],
    main_class = "scala.scalanative.bazel.NativeLinker",
    deps = [
        "@org_scala_native_tools//jar",
        "@org_scala_native_nativelib//jar",
        "@org_scala_native_javalib//jar",
        "@org_scala_native_scalalib//jar",
        "@org_scala_native_auxlib//jar",
        "@org_scala_native_util//jar",
        "@org_scala_native_nir//jar",
    ],
    # TODO: make it private beceuse it is in the private folder.
    visibility = ["//visibility:public"],
)
