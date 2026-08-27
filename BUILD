# For //tools:lint_check, which requires a `workspace` attribute. However, this
# can be any file, and `WORKSPACE` is going away one day. See:
# https://github.com/bazelbuild/buildtools/blob/v8.2.1/buildifier/runner.bash.template
exports_files(["MODULE.bazel"])

# For //test/scala_config:config_bzl_reflects_scala_version_test, which reads this
# repo rule's generated output; listing it in that test's `data` re-keys the test
# when the generation logic changes.
exports_files(["scala_config.bzl"])

# Declared inputs of the nested `bazel` tests: it reads the repo `.bazelrc`,
# resolves dependencies from the lock and runs the version bazelisk picks, so
# all three decide their outcome. See //test/expect_build_failure.
exports_files([
    ".bazelrc",
    ".bazelversion",
    "MODULE.bazel.lock",
])
