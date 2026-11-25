load("@rules_scala//scala:scala_export.bzl", "scala_export")

scala_export(
    name = "greeter",
    srcs = ["Greeter.scala"],
    # Scala libraries usually add the Scala binary version to the artifact.
    maven_coordinates = "com.example:greeter_2.13:1.0.0",
    deps = ["@maven//:com_google_guava_guava"],
)
