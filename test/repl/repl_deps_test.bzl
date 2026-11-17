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

def _scala_3_8_and_later_have_extra_deps_test(ctx):
    env = unittest.begin(ctx)

    deps_3_8 = repl_extra_deps("3.8.4")
    deps_3_9 = repl_extra_deps("3.9.0")
    deps_3_10 = repl_extra_deps("3.10.1")

    for dep in ["@io_bazel_rules_scala_scala_repl", "@com_lihaoyi_pprint"]:
        asserts.true(env, dep in deps_3_8, "expected %s in 3.8's repl deps" % dep)
    for dep in ["@io_bazel_rules_scala_scala_repl", "@org_jline_jline_reader"]:
        asserts.true(env, dep in deps_3_9, "expected %s in 3.9's repl deps" % dep)
    asserts.equals(env, deps_3_9, deps_3_10, "expected 3.9 and 3.10 to share repl deps")
    asserts.true(
        env,
        "@com_lihaoyi_pprint" not in deps_3_9,
        "expected 3.9's repl deps to stay clear of pprint, dropped since 3.8",
    )

    return unittest.end(env)

def _known_supported_versions_test(ctx):
    env = unittest.begin(ctx)

    for scala_version in ["2.12.21", "3.1.3", "3.7.4", "3.8.4", "3.9.0", "3.10.1"]:
        asserts.true(
            env,
            repl_is_known_supported(scala_version),
            "expected Scala %s to be known-supported" % scala_version,
        )

    return unittest.end(env)

versions_with_no_extra_deps_test = unittest.make(_versions_with_no_extra_deps_test)
scala_3_8_and_later_have_extra_deps_test = unittest.make(_scala_3_8_and_later_have_extra_deps_test)
known_supported_versions_test = unittest.make(_known_supported_versions_test)

def repl_deps_test_suite(name):
    unittest.suite(
        name,
        versions_with_no_extra_deps_test,
        scala_3_8_and_later_have_extra_deps_test,
        known_supported_versions_test,
    )
