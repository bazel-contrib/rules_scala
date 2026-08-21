load(
    "round_trip_test.bzl",
    "scalafmt_round_trip_test",
)
load(
    "scalafmt_rules.bzl",
    "scalafmt_scala_binary",
    "scalafmt_scala_library",
    "scalafmt_scala_test",
)

filegroup(
    name = "scala2-conf",
    srcs = [".scalafmt2.conf"],
)

filegroup(
    name = "scala3-conf",
    srcs = [".scalafmt3.conf"],
)

scalafmt_scala_library(
    name = "unformatted-library2",
    srcs = ["unformatted/unformatted-library2.scala"],
    config = ":scala2-conf",
    format = True,
    scala_version = "2.13.18",
)

scalafmt_scala_library(
    name = "formatted-library2",
    srcs = ["formatted/formatted-library2.scala"],
    config = ":scala2-conf",
    format = True,
    scala_version = "2.13.18",
)

scalafmt_scala_library(
    name = "unformatted-library3",
    srcs = ["unformatted/unformatted-library3.scala"],
    config = ":scala3-conf",
    format = True,
    scala_version = "3.3.8",
)

scalafmt_scala_library(
    name = "formatted-library3",
    srcs = ["formatted/formatted-library3.scala"],
    config = ":scala3-conf",
    format = True,
    scala_version = "3.3.8",
)

scalafmt_scala_binary(
    name = "unformatted-binary2",
    srcs = ["unformatted/unformatted-binary2.scala"],
    config = ":scala2-conf",
    format = True,
    main_class = "UnformattedBinary",
    scala_version = "2.12.21",
)

scalafmt_scala_binary(
    name = "formatted-binary2",
    srcs = ["formatted/formatted-binary2.scala"],
    config = ":scala2-conf",
    format = True,
    main_class = "UnformattedBinary",
    scala_version = "2.12.21",
)

scalafmt_scala_binary(
    name = "unformatted-binary3",
    srcs = ["unformatted/unformatted-binary3.scala"],
    config = ":scala3-conf",
    format = True,
    main_class = "UnformattedBinary",
    scala_version = "3.2.2",
)

scalafmt_scala_binary(
    name = "formatted-binary3",
    srcs = ["formatted/formatted-binary3.scala"],
    config = ":scala3-conf",
    format = True,
    main_class = "UnformattedBinary",
    scala_version = "3.2.2",
)

scalafmt_scala_test(
    name = "unformatted-test2",
    srcs = ["unformatted/unformatted-test2.scala"],
    config = ":scala2-conf",
    format = True,
    scala_version = "2.12.21",
)

scalafmt_scala_test(
    name = "formatted-test2",
    srcs = ["formatted/formatted-test2.scala"],
    config = ":scala2-conf",
    format = True,
    scala_version = "2.12.21",
)

#default scala version is 3.1.3
scalafmt_scala_test(
    name = "unformatted-test3",
    srcs = ["unformatted/unformatted-test3.scala"],
    config = ":scala3-conf",
    format = True,
)

scalafmt_scala_test(
    name = "formatted-test3",
    srcs = ["formatted/formatted-test3.scala"],
    config = ":scala3-conf",
    format = True,
)

scalafmt_round_trip_test(
    name = "binary2_test",
    filename = "binary2",
    rule_type = "binary2",
)

scalafmt_round_trip_test(
    name = "binary3_test",
    filename = "binary3",
    rule_type = "binary3",
)

scalafmt_round_trip_test(
    name = "library2_test",
    filename = "library2",
    rule_type = "library2",
)

scalafmt_round_trip_test(
    name = "library3_test",
    filename = "library3",
    rule_type = "library3",
)

scalafmt_round_trip_test(
    name = "test2_test",
    filename = "test2",
    rule_type = "test2",
)

scalafmt_round_trip_test(
    name = "test3_test",
    filename = "test3",
    rule_type = "test3",
)
