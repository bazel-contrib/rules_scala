# Downstream tests

Each fetches a real, independently-maintained external project at a pinned
commit as a Bazel-native external repo (`MODULE.bazel`'s
`downstream_consumers` extension, backed by `downstream_repository.bzl`),
patching in `local_path_override(rules_scala)` so it builds against *this*
checkout instead of a released version, then runs its own test suite
against it.

Every target here is tagged `manual`, so a plain `bazel test //...` (this
repo's own CI tasks run that wildcard) never picks them up -- cloning and
testing a full external project is slow and network-dependent. `manual`
excludes wildcard patterns too (`//test/community_build/...`,
`//test/community_build:all` -- neither finds any test targets), so name
each one explicitly instead:

```sh
bazel test --test_env=PATH //test/community_build:joern_test
```

Run both together the same way, just with both names on one command line:

```sh
bazel test --test_env=PATH //test/community_build:joern_test //test/community_build:dicer_test
```

(`--test_env=PATH`: the nested `bazel` invocation needs the *consumer's*
pinned Bazel version, not this checkout's -- see `downstream_test_driver.sh`.)

Each run executes for real, never from Bazel's test-result cache (the
targets are tagged `external`): the nested build reads this checkout's live
source tree, so rules_scala's own sources are code under test without being
declared inputs of the `sh_test` -- a cached PASS would survive edits to
them.

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
   `downstream_consumers.consumer(name = ..., remote = ..., commit = ...,
   scala_version = ...)` -- this is the one place a consumer's pin lives.
2. If it needs consumer-specific patching (e.g. dicer's protobuf-version
   override), add it to `_CONSUMER_PATCH_CMDS` in `downstream_repository.bzl`,
   keyed by name.
3. Add a `downstream_test(...)` target in `BUILD`, `load()`-ing its
   `scala_version` from `@<name>//_bazel_native_marker:version.bzl` (see the
   existing targets) rather than repeating the pin as a separate literal,
   with a target pattern (prefer `//...` plus negative patterns for
   known-bad exclusions over a hand-picked allowlist).
