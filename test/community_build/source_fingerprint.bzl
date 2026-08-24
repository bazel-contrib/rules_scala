"""A repository whose one file lists every file under scala/, src/, and
third_party/ with its content hash -- the trees a downstream consumer's
`local_path_override` (see downstream_repository.bzl) can reach. test/,
examples/, and docs/ are not part of the module's exposed surface.

`downstream_test` declares this file as `data`, so an edit anywhere under the
three roots changes it, and `joern_test`/`dicer_test` re-run; nothing under
them changes it, and an unrelated rerun is served `(cached) PASSED`.

Unlike a `local = True` repository rule, `repository_ctx.watch_tree` ties
re-evaluation to Bazel's own file-watching (added in Bazel 7.1.0 specifically
to replace `local`'s unreliable invalidation -- see
https://github.com/bazelbuild/bazel/issues/16217) rather than "always treat as
stale", so this is skipped whenever nothing in the three trees changed.
"""

_ROOTS = ["scala", "src", "third_party"]

def _impl(repository_ctx):
    root = repository_ctx.path(Label("//:MODULE.bazel")).dirname
    for name in _ROOTS:
        repository_ctx.watch_tree(root.get_child(name))

    result = repository_ctx.execute(
        ["sh", "-c", "find %s -type f | sort | xargs sha256sum" % " ".join(_ROOTS)],
        working_directory = str(root),
    )
    if result.return_code != 0:
        fail("Hashing scala/src/third_party failed: %s" % result.stderr)

    repository_ctx.file("fingerprint.txt", content = result.stdout)
    repository_ctx.file("BUILD", content = 'exports_files(["fingerprint.txt"])\n')

source_fingerprint = repository_rule(
    implementation = _impl,
    doc = "Hashes every file under scala/, src/, third_party/ into one file.",
)
