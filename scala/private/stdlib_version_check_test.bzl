"""Unit tests for stdlib_version_check.bzl's pure parsing/comparison functions.

//test/scala3_library_eviction covers these end-to-end, through jar
basenames from external repos; this file targets edge cases that would be
expensive to build a full fixture for (e.g. classifier jars).
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load(":stdlib_version_check.bzl", "compat_key", "stdlib_jar_version")

# attr.string() only carries string values, so a non-match is expressed as ""
# for both expected_artifact and expected_version (the defaults below).
def _stdlib_jar_version_test(ctx):
    env = unittest.begin(ctx)
    artifact, version = stdlib_jar_version(ctx.attr.basename)
    asserts.equals(env, ctx.attr.expected_artifact, artifact if artifact != None else "")
    asserts.equals(env, ctx.attr.expected_version, version if version != None else "")
    return unittest.end(env)

stdlib_jar_version_test = unittest.make(
    _stdlib_jar_version_test,
    attrs = {
        "basename": attr.string(),
        "expected_artifact": attr.string(default = ""),
        "expected_version": attr.string(default = ""),
    },
)

def _compat_key_test(ctx):
    env = unittest.begin(ctx)
    asserts.equals(env, ctx.attr.expected, compat_key(ctx.attr.artifact, ctx.attr.version))
    return unittest.end(env)

compat_key_test = unittest.make(
    _compat_key_test,
    attrs = {
        "artifact": attr.string(),
        "version": attr.string(),
        "expected": attr.string(),
    },
)

def _test_stdlib_jar_version():
    stdlib_jar_version_test(
        name = "stdlib_jar_version_scala3_library_test",
        basename = "scala3-library_3-3.7.4.jar",
        expected_artifact = "scala3-library_3-",
        expected_version = "3.7.4",
    )
    stdlib_jar_version_test(
        name = "stdlib_jar_version_scala_library_test",
        basename = "scala-library-2.13.18.jar",
        expected_artifact = "scala-library-",
        expected_version = "2.13.18",
    )
    stdlib_jar_version_test(
        name = "stdlib_jar_version_stamped_test",
        basename = "scala3-library_3-3.7.4-stamped.jar",
        expected_artifact = "scala3-library_3-",
        expected_version = "3.7.4",
    )
    stdlib_jar_version_test(
        name = "stdlib_jar_version_header_prefixed_test",
        basename = "header_scala3-library_3-3.7.4.jar",
        expected_artifact = "scala3-library_3-",
        expected_version = "3.7.4",
    )
    stdlib_jar_version_test(
        name = "stdlib_jar_version_header_prefixed_and_stamped_test",
        basename = "header_scala3-library_3-3.7.4-stamped.jar",
        expected_artifact = "scala3-library_3-",
        expected_version = "3.7.4",
    )

    # No match: scala-library-utils merely shares the prefix.
    stdlib_jar_version_test(
        name = "stdlib_jar_version_coincidental_prefix_test",
        basename = "scala-library-utils-1.0.jar",
    )

    # No match: a sources/javadoc classifier jar.
    stdlib_jar_version_test(
        name = "stdlib_jar_version_sources_classifier_test",
        basename = "scala3-library_3-3.3.1-sources.jar",
    )
    stdlib_jar_version_test(
        name = "stdlib_jar_version_javadoc_classifier_test",
        basename = "scala3-library_3-3.3.1-javadoc.jar",
    )

    # No match: unrelated jar.
    stdlib_jar_version_test(
        name = "stdlib_jar_version_unrelated_jar_test",
        basename = "guava-21.0.jar",
    )

    # No match: a .txt file.
    stdlib_jar_version_test(
        name = "stdlib_jar_version_non_jar_test",
        basename = "scala3-library_3-3.7.4.txt",
    )

def _test_compat_key():
    compat_key_test(
        name = "compat_key_scala_library_ignores_patch_test",
        artifact = "scala-library-",
        version = "2.12.21",
        expected = "2.12",
    )
    compat_key_test(
        name = "compat_key_scala3_library_exact_test",
        artifact = "scala3-library_3-",
        version = "3.7.4",
        expected = "3.7.4",
    )

def stdlib_version_check_test_suite():
    _test_stdlib_jar_version()
    _test_compat_key()

    native.test_suite(
        name = "stdlib_version_check_tests",
        tests = [
            ":stdlib_jar_version_scala3_library_test",
            ":stdlib_jar_version_scala_library_test",
            ":stdlib_jar_version_stamped_test",
            ":stdlib_jar_version_header_prefixed_test",
            ":stdlib_jar_version_header_prefixed_and_stamped_test",
            ":stdlib_jar_version_coincidental_prefix_test",
            ":stdlib_jar_version_sources_classifier_test",
            ":stdlib_jar_version_javadoc_classifier_test",
            ":stdlib_jar_version_unrelated_jar_test",
            ":stdlib_jar_version_non_jar_test",
            ":compat_key_scala_library_ignores_patch_test",
            ":compat_key_scala3_library_exact_test",
        ],
    )
