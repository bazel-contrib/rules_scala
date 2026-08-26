# Downstream tests

Each fetches a real, independently-maintained external project at a pinned
commit as a Bazel-native external repo (`MODULE.bazel`'s
`downstream_consumers` extension, backed by `downstream_repository.bzl`),
patching in `local_path_override(rules_scala)` so it builds against *this*
checkout instead of a released version, then runs its own test suite
against it.

A plain `bazel test //...` (this repo's own CI tasks run that wildcard)
picks these targets up: their nested `bazel test` of a full external
project is why they're the slowest targets in that run. Running one by
name instead is faster for local iteration:

```sh
bazel test --test_env=PATH //test/community_build:joern_test
```

Run both together the same way, just with both names on one command line:

```sh
bazel test --test_env=PATH //test/community_build:joern_test //test/community_build:dicer_test
```

(`--test_env=PATH`: the nested `bazel` invocation needs the *consumer's*
pinned Bazel version, not this checkout's -- see `downstream_test_driver.sh`.)

A rerun with nothing relevant changed is served `(cached) PASSED`: the
nested build reads this checkout's live source tree, so rules_scala's own
sources would otherwise be code under test without being declared inputs
of the `sh_test` (a cached PASS surviving an edit to them). Instead, both
targets declare `@rules_scala_source_fingerprint//:fingerprint.txt` (see
`source_fingerprint.bzl`) as `data` -- a hash of every file rules_scala
exposes to a downstream consumer -- so an edit anywhere in scope changes it
and forces a real re-run.

## What these cover -- and what they deliberately don't

joern and dicer between them exercise `scala_library`, `scala_test`,
`scala_binary`, `scala_proto`/ScalaPB, and custom toolchain registration,
on Scala 3 and 2.12. No consumer here exercises `scala_junit_test`, specs2,
`scala_library_suite`, twitter_scrooge, scalafmt, semanticdb, or the
coverage path -- as of mid-2026 no live, publicly buildable Bzlmod project
using those could be found (the historical heavy users, e.g. Wix's specs2
codebase, are closed-source or long unmaintained). Those surfaces are
covered by this repo's own tests and `examples/` instead; a synthetic
downstream consumer would only duplicate `examples/` while adding none of
the realism that is the entire point here. If a real consumer of those APIs
appears, add it.

## Adding a consumer

1. Declare it in the root `MODULE.bazel`, via
   `downstream_consumers.consumer(name = ..., remote = ..., commit = ...)`.
   If it needs consumer-specific patching (e.g. dicer's protobuf-version
   override), add a patch file and pass it via that same call's `patches`
   arg (like `http_archive`'s).
2. Add a `downstream_test(...)` target in `BUILD`, with its `scala_version`
   as a literal matching the `MODULE.bazel` pin (see the existing targets
   and the comment above them) and a target pattern (prefer `//...` plus
   negative patterns for known-bad exclusions over a hand-picked allowlist).
