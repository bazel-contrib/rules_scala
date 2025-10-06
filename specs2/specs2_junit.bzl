load("//specs2:specs2.bzl", "specs2_dependencies")

def specs2_junit_dependencies():
    return specs2_dependencies() + [
        Label("//testing/toolchain:specs2_junit_classpath"),
    ]
