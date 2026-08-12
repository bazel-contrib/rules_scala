# Asserting that a build or a test fails

Two mechanisms live here. Pick by *when* the failure happens.

## Analysis-time failure: use `expect_analysis_failure_test`

A target that Bazel rejects while analysing it -- a `fail()` in a rule, a bad
attribute combination -- needs no build at all. `expect_analysis_failure_test`
(see `expect_analysis_failure.bzl`) asks Bazel in-process through
`bazel_skylib`'s `analysistest`. It is hermetic, cacheable and runs in under a
second.

## Execution-time failure: use the `expect_*` macros

A compile error, a failing test binary, a warning printed by an action: these
only appear once actions run, and Bazel has no native rule for "run a build and
assert it fails". So `expect_build_failure.bzl` wraps an `sh_test` around a
**nested `bazel`** invocation.

That nested build reads the real source tree, which the outer Bazel cannot see,
so the test has to declare by hand everything that decides its outcome. The
macro does that for you; the docstring in `expect_build_failure.bzl` lists what
goes into the cache key and what stays outside it.

Nothing re-runs these tests without the result cache on a schedule. That would be
the way to catch an input nobody thought to declare.

## What to delete later

- **On Bazel 8 or newer**, an aspect can reach toolchain dependencies through
  `aspect(toolchains_aspects = ...)`. That replaces `_SCALAC_JAR` and
  `_RUNNER_JARS`, which exist only because the fingerprint carries the tools'
  paths and not their content. This repo pins 7.7.1 in `.bazelversion`, where
  the parameter does not exist.
- **The success cases do not need a nested build at all.** A Starlark transition
  can set `//command_line_option:extra_toolchains`, verified on Bazel 7.7.1: the
  same fixture fails with the `-Xmx1M` toolchain and builds with the `-Xmx1G` one
  when the flag is set that way. Of the 61 tests here, 41 assert a failure and do
  need the nested build, because a target that fails cannot be a dependency. The
  other 20 assert success: 17 of those only set flags and check nothing about the
  output, so a transition plus `build_test` covers them, and 1 sets no flags at
  all and needs only `build_test`. The last 2 assert on build output, which only
  a real invocation produces. Those 18 took 180s of the 653s a full local run
  spends here, all of it on the critical path because of `exclusive`.
- **The whole nested driver** would go away by moving these tests to
  [`rules_bazel_integration_test`](https://github.com/bazel-contrib/rules_bazel_integration_test),
  which gives each test its own child workspace and an explicit `workspace_files`
  attribute. Then the inputs are declared by construction rather than by hand,
  the shared output base disappears, and with it the `exclusive` tag that
  serialises these tests today. The cost is moving 27 fixture packages into
  child workspaces, so it is a project rather than a patch.

## When you add a test here

Nothing in a caller has to know about caching. Three things are worth knowing:

- If the fixture lives in another package, make it visible to yours; the
  fingerprint is a real dependency edge, unlike the label string the nested
  `bazel` receives.
- A nested build runs with a scrubbed `HOME`, so your `~/.bazelrc` is ignored.
  If you need it (a download proxy, say), set
  `RULES_SCALA_NESTED_BAZEL_USE_REAL_HOME=1`. Any failing nested build says so.
- Analysis fails if the fingerprint carries no rules_scala action, because such
  a fingerprint cannot notice a change in the rules and the test it keys would
  stay green through a regression. Either point `fingerprint_target` at a label
  the nested build really compiles, or say why you cannot with
  `no_fingerprint_reason`, which tags the test `external` so it re-runs every
  time rather than being served a pass it cannot vouch for. Seven tests do that
  today: `scala_proto` generates through an aspect of its own, whose actions
  this aspect cannot read, and the `semanticdb` fixtures only build toolchain
  deps, so they compile nothing at all.

What the fingerprint does not see: an action that writes a file instead of
running a command line (`ctx.actions.write`, template expansion) contributes its
mnemonic and nothing else, which is 446 of the 5135 lines it collects today. A
change to what such an action writes leaves the fingerprint identical. Declaring
those files instead would put output paths -- and with them the configuration --
back into the key, which is what makes the tests re-run under every flag the
outer build sets.

## Registering a toolchain

A toolchain the nested build registers decides whether that build fails, and it
is not part of the fixture's own graph. The macro handles this on its own: it
reads the `--extra_toolchains` flags out of the arguments it forwards and
analyses the fixture under exactly those toolchains, through a Starlark
transition on `//command_line_option:extra_toolchains`. Change a toolchain and
the command lines in the fingerprint change with it, so the test re-runs.

Nothing to declare in the toolchain's package, in other words. Verified by
setting `unused_dependency_checker_mode`, `strict_deps_mode` and
`dependency_mode` in `//scala:minimal_direct_source_deps` to values that would
make the assertion vacuous: each moves the fingerprint of the test that
registers it.
