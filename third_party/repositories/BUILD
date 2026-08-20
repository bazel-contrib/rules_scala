# For //test/scala_config:scalac_javac_uses_scala_library_*_test, which assert the
# scala-library coordinate these files pin lands on the scalac classpath; listing
# them in those tests' `data` re-keys the tests when a coordinate is bumped.
exports_files([
    "scala_2_12.bzl",
    "scala_2_13.bzl",
])

# For //test/compiler_sources_integrity_test:latest_version_*_no_warning_test,
# which build under each of these files' pinned scala_version; listing them in
# those tests' `data` re-keys the tests when a version is bumped.
exports_files([
    "scala_2_11.bzl",
    "scala_3_1.bzl",
    "scala_3_2.bzl",
    "scala_3_3.bzl",
    "scala_3_4.bzl",
    "scala_3_5.bzl",
    "scala_3_6.bzl",
    "scala_3_7.bzl",
    "scala_3_8.bzl",
])
