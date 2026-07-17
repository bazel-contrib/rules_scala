#!/usr/bin/env bash
#
# "Dogfood" tests: build real, independently-maintained external projects
# that depend on rules_scala, pointed at *this* checkout instead of their
# pinned released version, to catch consumer-breaking changes before they
# ship.
#
# Every test function here is prefixed with `_` (see test_runner.sh's
# `_skip_test`), so `run_tests` skips them by default -- these clone a large
# external repo and fetch its Maven dependencies, which is slow and
# network-dependent, so they are not yet wired into `.bazelci/presubmit.yml`.
# Run one explicitly with, e.g.:
#
#   RULES_SCALA_TEST_ONLY=_test_dogfood_lila_scala213 ./test_dogfood.sh
#
# To promote a test to run automatically in CI: drop its `_` prefix and add a
# task for it (calling this script) to `.bazelci/presubmit.yml`, same as any
# other `test_*.sh` here.

set -euo pipefail

dir="$( cd "${BASH_SOURCE[0]%/*}" && echo "${PWD%/test/shell}" )"
test_source="${dir}/test/shell/${BASH_SOURCE[0]#*test/shell/}"
# shellcheck source=./test_runner.sh
. "${dir}"/test/shell/test_runner.sh

# Clones `consumer_repo` at the exact pinned commit `consumer_sha` (never a
# floating branch tip -- an unrelated upstream break in a consumer shouldn't
# make our CI flaky) and builds `target` against this rules_scala checkout,
# working around the friction points found while spiking this against real
# consumers (see meets notes):
#
#   1. The consumer's exact `scala_version` pin may not match a version this
#      checkout's `third_party` repos carry -- forced via
#      `--repo_env=SCALA_VERSION`, so we build with whatever patch version
#      this checkout actually has rather than the consumer's exact pin.
#   2. `maven_install.json`'s signature can go stale under a different local
#      Bazel version than the consumer was pinned against -- repinned
#      unconditionally rather than trusting the checked-in lockfile.
#
# Args:
#   consumer_repo: git URL to clone.
#   consumer_sha: exact commit SHA to fetch (works even if it's not the tip
#     of any branch GitHub advertises, since GitHub allows fetching any
#     reachable commit by SHA for public repos).
#   scala_version: value to force via --repo_env=SCALA_VERSION (must be one
#     this checkout's third_party repos carry -- see SCALA_VERSIONS in the
#     root MODULE.bazel).
#   target: Bazel target(s) to build in the consumer repo, e.g. "//foo:bar".
#   patch_fn: name of a function (or "") to call, with the consumer repo as
#     cwd, to work around consumer-specific quirks before building (e.g. a
#     gazelle setup that references a sibling repo that doesn't exist here).
_dogfood_build() {
  local consumer_repo="$1"
  local consumer_sha="$2"
  local scala_version="$3"
  local target="$4"
  local patch_fn="${5:-}"

  local rules_scala_dir="$dir"
  local work_dir
  work_dir="$(mktemp -d)"
  # shellcheck disable=SC2064
  trap "rm -rf '${work_dir}'" RETURN

  git init --quiet "${work_dir}/consumer"
  cd "${work_dir}/consumer"
  git remote add origin "$consumer_repo"
  git fetch --quiet --depth 1 origin "$consumer_sha"
  git checkout --quiet FETCH_HEAD

  cat >>MODULE.bazel <<EOF

local_path_override(
    module_name = "rules_scala",
    path = "${rules_scala_dir}",
)
EOF

  if [[ -n "$patch_fn" ]]; then
    "$patch_fn"
  fi

  REPIN=1 bazel run --repo_env=SCALA_VERSION="$scala_version" @maven//:pin
  # shellcheck disable=SC2086 # intentional word-splitting: `target` may be
  # multiple space-separated Bazel targets.
  bazel build --repo_env=SCALA_VERSION="$scala_version" $target
}

# lila (Lichess) pins gazelle for BUILD-file generation, with a
# `local_path_override` for `scala_gazelle` pointing at a sibling checkout
# (`../../../bazel/foursquare_scala-gazelle/`) that only exists on the
# author's machine. A bare stub module isn't enough to work around this: the
# `go_deps` module extension gets evaluated for *any* bazel invocation, not
# just BUILD regeneration, because `register_toolchains` forces loading the
# root BUILD package, which pulls in gazelle's own toolchain machinery. A
# dogfood job that only builds/tests never needs BUILD-file regeneration, so
# we strip the gazelle/scala_gazelle/go_deps wiring entirely instead.
_dogfood_lila_strip_gazelle() {
  awk '
    BEGIN { skip = 0 }
    skip == 0 && /^bazel_dep\(name = "gazelle"/ { skip = 1; next }
    skip == 1 && /go-tree-sitter/ { skip = 2; next }
    skip == 2 { skip = 0; next }
    skip == 1 { next }
    { print }
  ' MODULE.bazel >MODULE.bazel.tmp
  mv MODULE.bazel.tmp MODULE.bazel

  awk '
    BEGIN { skip = 0 }
    /^load\("@gazelle\/\/:def\.bzl"/ { next }
    skip == 0 && /^# foursquare\/scala-gazelle$/ { skip = 1; next }
    skip == 1 && /gazelle = ":scala_gazelle",/ { skip = 2; next }
    skip == 2 { skip = 0; next }
    skip == 1 { next }
    { print }
  ' BUILD >BUILD.tmp
  mv BUILD.tmp BUILD
}

# Pinned to the tip of `scala_2.13_generated` as of 2026-07-16.
_test_dogfood_lila_scala213() {
  _dogfood_build \
    "https://github.com/WojciechMazur/lila.git" \
    "43966e10e0f4cebb9b52dbb60394ebe5ff75fa23" \
    "2.13.18" \
    "//modules/common:common" \
    "_dogfood_lila_strip_gazelle"
}

# Currently fails: lila pins `scala_version = "3.7.0"` on this branch, but
# this checkout's SCALA_3_VERSIONS only carries "3.7.4" (see root
# MODULE.bazel), and `modules/core` fails to compile under 3.7.4 with
# "object internal does not have a member method erasedValue" -- a
# compiler-internal API (used by macro/derivation code) that appears to have
# shifted between those two patch releases. Unrelated to any rules_scala
# production code; needs its own follow-up (e.g. an exact-3.7.0 third_party
# entry, or a different Scala 3 target) before this is dogfood-worthy.
#
# Pinned to the tip of `scala_3_generated` as of 2026-07-16.
_test_dogfood_lila_scala3() {
  _dogfood_build \
    "https://github.com/WojciechMazur/lila.git" \
    "29fdf5246e0325b6cc3427069e446ee31c1c9510" \
    "3.7.4" \
    "//modules/common:common" \
    "_dogfood_lila_strip_gazelle"
}

# databricks/dicer pins `protobuf` to an exact version (with a local patch,
# for an unrelated legacy Python-toolchain registration bug) via its own
# root-module `single_version_override`. `single_version_override` /
# `multiple_version_override` directives are only honored from the *root*
# module of a build -- and once we build from inside dicer's checkout,
# dicer's own MODULE.bazel *is* the root, so this checkout's rules_scala//`
# single_version_override(protobuf, "33.5")` (see root MODULE.bazel) is
# silently ignored in favor of dicer's "30.2". The scalapb/protoc tooling
# rules_scala's `scala_proto` extension bundles is generated against 33.5's
# gencode, so building against 30.2's older runtime fails hard at codegen
# time ("Detected incompatible Protobuf Gencode/Runtime versions"). Fix: take
# over dicer's override ourselves, bumping it to what this checkout expects
# and dropping its now-inapplicable patch.
_dogfood_dicer_bump_protobuf() {
  awk '
    /^single_version_override\($/ { buffering = 1; n = 0; buf[n++] = $0; next }
    buffering {
      buf[n++] = $0
      if ($0 == ")") {
        is_protobuf = 0
        for (i = 0; i < n; i++) if (buf[i] ~ /module_name = "protobuf"/) is_protobuf = 1
        if (is_protobuf) {
          print "single_version_override("
          print "    module_name = \"protobuf\","
          print "    version = \"33.5\","
          print ")"
        } else {
          for (i = 0; i < n; i++) print buf[i]
        }
        buffering = 0
        next
      }
      next
    }
    { print }
  ' MODULE.bazel >MODULE.bazel.tmp
  mv MODULE.bazel.tmp MODULE.bazel
}

# Pinned to the tip of `master` as of 2026-07-16.
_test_dogfood_dicer() {
  _dogfood_build \
    "https://github.com/databricks/dicer.git" \
    "5cce7985352c51c00890ca1bdb2c3667a3102569" \
    "2.12.21" \
    "//dicer/common:generation" \
    "_dogfood_dicer_bump_protobuf"
}

# joern's MODULE.bazel pulls two of its own dependencies (`codepropertygraph`,
# `bazel_tooling`) via `git_override(remote = "git@github.com:...")` -- SSH,
# not HTTPS. Both repos are public, but Bazel's `git_repository` rule shells
# out to the system `git`, which fails outright without an SSH key/known-hosts
# entry ("Host key verification failed"). Rewriting the URL via git's own
# `url.<base>.insteadOf` config -- scoped to this process only, via
# `GIT_CONFIG_GLOBAL` -- makes git use anonymous HTTPS instead, without
# touching joern's MODULE.bazel or this machine's real git config.
_dogfood_joern_use_https_git() {
  local rewrite_config
  rewrite_config="$(mktemp)"
  cat >"$rewrite_config" <<'EOF'
[url "https://github.com/"]
    insteadOf = git@github.com:
EOF
  export GIT_CONFIG_GLOBAL="$rewrite_config"
}

# Pinned to the tip of `master` as of 2026-07-16.
_test_dogfood_joern() {
  _dogfood_build \
    "https://github.com/joernio/joern.git" \
    "7da091d0a6a860a89d411ee04e3a7e696dbdf6b1" \
    "3.7.4" \
    "//semanticcpg:semanticcpg" \
    "_dogfood_joern_use_https_git"
}

run_tests "$test_source" "$(get_test_runner "${1:-local}")"
