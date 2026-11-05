load("//scala:scala_toolchain.bzl", "scala_toolchain")

scala_toolchain(
    name = "postfix_ops_impl",
    scalacopts = [
        "-language:postfixOps",
        "-Wconf:msg=a -bogus:s",
    ],
)

toolchain(
    name = "postfix_ops",
    target_settings = ["@rules_scala_config//:scala_version_2_13_18"],
    toolchain = ":postfix_ops_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//test/scaladoc:__pkg__"],
)

scala_toolchain(
    name = "kind_projector_impl",
    plugins = ["@rules_scala_test_maven//:org_typelevel_kind_projector_2_12_20"],
)

toolchain(
    name = "kind_projector",
    target_settings = ["@rules_scala_config//:scala_version_2_12_21"],
    toolchain = ":kind_projector_impl",
    toolchain_type = "//scala:toolchain_type",
    visibility = ["//test/scaladoc:__pkg__"],
)
