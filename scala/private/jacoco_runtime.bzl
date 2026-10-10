"""JaCoCo runtime for tools that run other targets' code during the build."""

# Some tools run code from other targets while they build: scalac and scaladoc
# run macros, code generators run generator classes. In a coverage build
# (`bazel coverage` or `--collect_code_coverage`), JaCoCo has instrumented that
# code, so each of its classes calls the JaCoCo runtime library when it loads.
# These tools therefore need the runtime library on their own classpath, or
# they fail with NoClassDefFoundError.
#
# The runtime also counts which lines ran, and by default saves the counts to a
# jacoco.exec file in the current directory when the tool exits. Coverage
# reports come only from test runs, so `jacoco-agent.output=none` turns that
# file off.
JACOCO_RUNTIME_DEPS = [Label("@bazel_tools//tools/jdk:JacocoCoverage")]
JACOCO_RUNTIME_JVM_FLAGS = ["-Djacoco-agent.output=none"]
