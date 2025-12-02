load("//scala:scala.bzl", "scala_library", "scala_test")

# Original library with the class to be shadowed
scala_library(
    name = "original",
    srcs = ["Original.scala"],
)

# Library that shadows the Overridable class with a Java file
# The Java file (Overridable.java) should take precedence over
# the Overridable class from the :original dependency
scala_library(
    name = "with_java_override",
    srcs = ["Overridable.java"],
    deps = [":original"],
)

# Test that verifies the Java override works correctly
scala_test(
    name = "verify_override_test",
    srcs = ["VerifyOverride.scala"],
    deps = [":with_java_override"],
)

