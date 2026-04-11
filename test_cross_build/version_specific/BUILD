load("@rules_scala//scala:scala.bzl", "scala_library")

# A collection of arbitrarily chosen backward- and forward-incompatible code.
# This simply tests if the proper compiler is assigned, according to Scala version setting.

# What's new in 3.3
scala_library(
    name = "since_3_3",
    srcs = ["since_3_3.scala"],
    scala_version = "3.3.7",
)

scala_library(
    name = "before_3_3",
    srcs = ["before_3_3.scala"],
    scala_version = "3.2.2",
)

# What's new in 3.2
scala_library(
    name = "since_3_2",
    srcs = ["since_3_2.scala"],
    scala_version = "3.2.2",
)

scala_library(
    name = "before_3_2",
    srcs = ["before_3_2.scala"],
    scala_version = "3.1.3",
)

# What's new in 3.1
scala_library(
    name = "since_3_1",
    srcs = ["since_3_1.scala"],
    scala_version = "3.1.3",
)

scala_library(
    name = "scala_3_3",
    srcs = [
        "since_3_1.scala",
        "since_3_2.scala",
        "since_3_3.scala",
    ],
    scala_version = "3.3.7",
)

scala_library(
    name = "scala_3_2",
    srcs = [
        "before_3_3.scala",
        "since_3_1.scala",
        "since_3_2.scala",
    ],
    scala_version = "3.2.2",
)

scala_library(
    name = "scala_3_1",
    srcs = [
        "before_3_2.scala",
        "before_3_3.scala",
        "since_3_1.scala",
    ],
    scala_version = "3.1.3",
)

# Cross-major-version targets (default 3.x -> target 2.x).
# test_cross_build_default_2x in test_cross_build.sh builds existing 3.x
# targets with --repo_env=SCALA_VERSION=2.13.18 to cover the reverse
# direction (default 2.x -> target 3.x).

scala_library(
    name = "scala_2_13",
    srcs = ["scala_2_only.scala"],
    scala_version = "2.13.18",
)

scala_library(
    name = "scala_2_12",
    srcs = ["scala_2_only.scala"],
    scala_version = "2.12.21",
)
