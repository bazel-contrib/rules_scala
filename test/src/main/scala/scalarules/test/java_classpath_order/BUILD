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
# Note: This test is incompatible with strict deps checking because the checker
# doesn't understand class shadowing - it sees Overridable as coming from :original
# rather than the shadowed version from :with_java_override
scala_test(
    name = "verify_override_test",
    srcs = ["VerifyOverride.scala"],
    unused_dependency_checker_mode = "off",
    deps = [":with_java_override"],
)
