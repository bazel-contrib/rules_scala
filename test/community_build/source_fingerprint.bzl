"""A repository whose one file lists every file rules_scala exposes to a
downstream consumer's `local_path_override` (see downstream_repository.bzl),
with its content hash.

`repository_ctx.watch_tree`'s `exclude` param (which would let this watch the
whole checkout root minus a short internal-only list) needs Bazel 8+; this
checkout pins 7.7.1 (.bazelversion). So instead `_PUBLIC_DIRS` below is the
list of top-level directories a `bazel_dep(rules_scala)` consumer can
actually load from -- verified against real `load()`s in docs/*.md,
examples/*/BUILD, and rules_scala's own scala/*.bzl (e.g. `scala/toolchains.bzl`
loads `//junit:junit.bzl`, `//specs2:specs2.bzl`, `//jmh/toolchain:toolchain.bzl`,
`//scalatest:scalatest.bzl` -- toolchain plumbing, not consumer-doc-page
material, but just as load-bearing) -- not just `scala/`, `src/`,
`third_party/`. `_INTERNAL_ENTRIES` are the rest of the top level: test/CI/dev
fixtures no consumer's build reaches. `exposed_top_level_dirs_test` fails
loudly, naming it, if a new top-level directory is in neither list -- so a
missed one shows up as a failing test, not a silently stale cache.

`downstream_test` declares this file as `data`, so an edit anywhere in scope
changes it, and `joern_test`/`dicer_test` re-run; nothing in scope changes it,
and an unrelated rerun is served `(cached) PASSED`.

Unlike a `local = True` repository rule, `repository_ctx.watch_tree` ties
re-evaluation to Bazel's own file-watching (added in Bazel 7.1.0 specifically
to replace `local`'s unreliable invalidation -- see
https://github.com/bazelbuild/bazel/issues/16217) rather than "always treat as
stale", so this is skipped whenever nothing in scope changed.
"""

load("@rules_shell//shell:sh_test.bzl", "sh_test")

# Verified against real load()s -- see the module docstring.
_PUBLIC_DIRS = [
    "scala",
    "src",
    "third_party",
    "scala_proto",
    "protoc",
    "testing",
    "thrift",
    "twitter_scrooge",
    "junit",
    "specs2",
    "jmh",
    "scalatest",
    "java_stub_template",
]

# Root-level files a downstream consumer's `local_path_override` also
# resolves against (MODULE.bazel decides this module's own dependency
# versions; the others are exports_files'd from the root BUILD).
_PUBLIC_ROOT_FILES = [
    "BUILD",
    "MODULE.bazel",
    "MODULE.bazel.lock",
    "scala_config.bzl",
]

# Test/CI/dev fixtures and repo metadata, none of it reachable from a
# consumer's build: directories, then loose root files. `.git` and `tmp`
# aren't source. Bazel's own convenience symlinks (`bazel-bin`, `bazel-out`,
# `bazel-testlogs`, `bazel-<checkout-dir-name>` -- the last one varies by
# checkout, e.g. differs in CI) are not listed here at all;
# exposed_top_level_dirs_test.sh skips anything matching `bazel-*` by pattern
# instead of by name.
_INTERNAL_ENTRIES = [
    ".bazelci",
    ".bazelignore",
    ".bazelrc",
    ".bazelversion",
    ".bcr",
    ".claude",
    ".gemini",
    ".git",
    ".github",
    ".gitignore",
    ".markdownlint.json",
    ".scalafmt.conf",
    "AUTHORS",
    "CODEOWNERS",
    "CONTRIBUTING.md",
    "CONTRIBUTORS",
    "Governance.md",
    "LICENSE.txt",
    "README.md",
    "WORKSPACE",
    "dangerous_test_thirdparty_version.sh",
    "deps",
    "docs",
    "dt_patches",
    "examples",
    "lint.sh",
    "manual_test",
    "scripts",
    "test",
    "test_all.sh",
    "test_cleanup.sh",
    "test_coverage.sh",
    "test_cross_build",
    "test_cross_build.sh",
    "test_dependency_versions.sh",
    "test_examples.sh",
    "test_expect_failure",
    "test_intellij_aspect.sh",
    "test_lint.sh",
    "test_reproducibility.sh",
    "test_rules_scala.sh",
    "test_statsfile",
    "test_thirdparty_version.sh",
    "test_version",
    "test_version.sh",
    "tmp",
    "tools",
]

def _impl(repository_ctx):
    root = repository_ctx.path(Label("//:MODULE.bazel")).dirname
    for name in _PUBLIC_DIRS:
        repository_ctx.watch_tree(root.get_child(name))
    for name in _PUBLIC_ROOT_FILES:
        repository_ctx.watch(root.get_child(name))

    result = repository_ctx.execute(
        # All paths (files and directories alike) must precede the `-type f`
        # expression -- some `find` implementations (e.g. BSD find on macOS)
        # reject a path argument once the expression has started.
        ["sh", "-c", "find %s %s -type f | sort | xargs sha256sum" % (
            " ".join(_PUBLIC_ROOT_FILES),
            " ".join(_PUBLIC_DIRS),
        )],
        working_directory = str(root),
    )
    if result.return_code != 0:
        fail("Hashing rules_scala's exposed sources failed: %s" % result.stderr)

    repository_ctx.file("fingerprint.txt", content = result.stdout)
    repository_ctx.file("BUILD", content = 'exports_files(["fingerprint.txt"])\n')

source_fingerprint = repository_rule(
    implementation = _impl,
    doc = "Hashes every file rules_scala exposes to a downstream consumer into one file.",
)

def exposed_top_level_dirs_test(name, **kwargs):
    """Fails if a top-level directory is neither in _PUBLIC_DIRS nor _INTERNAL_ENTRIES.

    Needs the real checkout, not just this test's runfiles, so it can `ls`
    the repo root -- same reason test/expect_build_failure's nested tests are
    tagged this way.
    """
    sh_test(
        name = name,
        srcs = ["exposed_top_level_dirs_test.sh"],
        args = _PUBLIC_DIRS + _PUBLIC_ROOT_FILES + ["--"] + _INTERNAL_ENTRIES,
        data = [
            # _nested_bazel_find_workspace resolves the real source root from
            # this symlink under `bazel test` (no BUILD_WORKSPACE_DIRECTORY).
            "//:MODULE.bazel",
            "//test/expect_build_failure:nested_bazel.sh",
        ],
        tags = ["no-sandbox", "external"],
        **kwargs
    )
