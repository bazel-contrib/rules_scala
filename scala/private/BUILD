# For //test/compiler_sources_integrity_test, whose tests build a fixture
# under this logic; listing these files in those tests' `data` re-keys the
# tests when the logic changes.
exports_files([
    "macros/compiler_sources_integrity.bzl",
    "macros/scala_repositories.bzl",
])

# Exported so a test can declare them as inputs. //test/scalac_exec_group drives
# nested `bazel` invocations against the real source tree, which Bazel cannot
# see as a dependency of the test: without naming these, a regression here is
# served a cached PASS instead of re-running the test.
exports_files(
    [
        "rule_impls.bzl",
        "rules/scala_binary.bzl",
        "rules/scala_junit_test.bzl",
        "rules/scala_library.bzl",
        "rules/scala_repl.bzl",
        "rules/scala_test.bzl",
    ],
    visibility = ["//test:__subpackages__"],
)

# For //test/semanticdb, whose tests build a fixture using this phase; listing
# it in those tests' `data` re-keys the tests when the phase's logic changes.
# fixture_actions can't see this on its own: the fixture's only own action is
# a template expansion, which fingerprints by mnemonic and not by content.
exports_files(["phases/phase_semanticdb.bzl"])
