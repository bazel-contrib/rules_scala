load("@rules_scala//scala:scala.bzl", "scala_binary", "scala_library", "scala_test")

# Here we demonstrate the simplest case,
# single binary, test or library for which we set a specific version or use the default one:

# This one will be compiled by 2.12 compiler:
scala_library(
    name = "lib212",
    srcs = ["lib.scala"],
    scala_version = "2.12.21",
)

# This one will be compiled by 2.13 compiler:
scala_test(
    name = "test213",
    srcs = ["test.scala"],
    scala_version = "2.13.18",
)

# This one will be compiled by 3.3 compiler (the default one):
scala_binary(
    name = "bin33",
    srcs = ["bin.scala"],
    main_class = "X",
)
