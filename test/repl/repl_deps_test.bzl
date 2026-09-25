"""Unit tests for repl_extra_deps/repl_is_known_supported (scala/private/macros/repl_deps.bzl).

Plain function calls, no target under test: these two functions take a
version string and return a value, nothing Bazel-specific, so a full
analysis test would only add overhead.
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load(
    "//scala/private:macros/repl_deps.bzl",
    "repl_extra_deps",
    "repl_is_known_supported",
)

def _versions_with_no_extra_deps_test(ctx):
    env = unittest.begin(ctx)

    # Scala 2 and Scala 3 versions before the repl-artifact split: nothing extra.
    for scala_version in ["2.12.21", "2.13.18", "3.1.3", "3.7.4"]:
        asserts.equals(
            env,
            [],
            repl_extra_deps(scala_version),
            "expected no extra repl deps for Scala %s" % scala_version,
        )

    return unittest.end(env)

def _mapped_3_8_and_3_9_have_extra_deps_test(ctx):
    """Checks each version's distinctive artifacts.

    Catches both a missing mapping and the two mappings getting swapped:
    fansi/pprint are 3.8-only (dropped in 3.9), and the jline4 artifacts are
    3.9-only (3.8 reuses the repo's existing jline 3.30.6 set). Both share
    org_scala_lang_scala3_repl -- the artifact this whole split is about.
    """
    env = unittest.begin(ctx)

    deps_3_8 = repl_extra_deps("3.8.4")
    deps_3_9 = repl_extra_deps("3.9.0")

    for dep in ["@org_scala_lang_scala3_repl", "@com_lihaoyi_fansi_3"]:
        asserts.true(env, dep in deps_3_8, "expected %s in 3.8's repl deps" % dep)
    asserts.true(
        env,
        "@com_lihaoyi_fansi_3" not in deps_3_9,
        "expected 3.9's repl deps to stay clear of fansi, dropped since 3.8",
    )

    for dep in ["@org_scala_lang_scala3_repl", "@org_jline_jline_reader_4"]:
        asserts.true(env, dep in deps_3_9, "expected %s in 3.9's repl deps" % dep)
    asserts.true(
        env,
        "@org_jline_jline_reader_4" not in deps_3_8,
        "expected 3.8's repl deps to stay on the repo's existing jline 3.30.6 set",
    )

    return unittest.end(env)

def _known_supported_versions_test(ctx):
    env = unittest.begin(ctx)

    for scala_version in ["2.12.21", "3.1.3", "3.7.4", "3.8.4", "3.9.0"]:
        asserts.true(
            env,
            repl_is_known_supported(scala_version),
            "expected Scala %s to be known-supported" % scala_version,
        )

    return unittest.end(env)

def _unmapped_future_version_is_not_known_supported_test(ctx):
    """The regression this whole file exists for.

    A Scala 3 minor >= 3.8 with no repl_extra_deps entry must come back
    False here, so scala_repl fails loudly at analysis time (see
    phase_write_executable_repl) instead of building a REPL that only fails
    once someone actually runs it.
    """
    env = unittest.begin(ctx)

    asserts.false(
        env,
        repl_is_known_supported("3.10.0"),
        "a Scala 3.10 with no repl_extra_deps entry must not read as known-supported",
    )

    return unittest.end(env)

versions_with_no_extra_deps_test = unittest.make(_versions_with_no_extra_deps_test)
mapped_3_8_and_3_9_have_extra_deps_test = unittest.make(_mapped_3_8_and_3_9_have_extra_deps_test)
known_supported_versions_test = unittest.make(_known_supported_versions_test)
unmapped_future_version_is_not_known_supported_test = unittest.make(_unmapped_future_version_is_not_known_supported_test)

def repl_deps_test_suite(name):
    unittest.suite(
        name,
        versions_with_no_extra_deps_test,
        mapped_3_8_and_3_9_have_extra_deps_test,
        known_supported_versions_test,
        unmapped_future_version_is_not_known_supported_test,
    )
