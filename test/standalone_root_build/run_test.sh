#!/usr/bin/env bash
# Runs `bazel build //...` inside a nested Bazel module, as that module's own
# build root, and asserts it succeeds.
#
# The modules covered here are also wired into the root MODULE.bazel as
# `dev_dependency` `local_path_override`s, so their own targets already get
# built and tested as part of this repo's own `bazel test //...` -- but only
# in the root's module-resolution context. A `single_version_override` on the
# root module (e.g. for `protobuf`) only applies when the root module is the
# actual build root, so building one of these modules as its OWN root can
# resolve different dependency versions than the ones already proven via the
# root's own build. This test covers that separately.
#
# Usage: run_test.sh <module-dir>
# <module-dir> is a repo-relative directory containing a MODULE.bazel file.

set -euo pipefail

if [[ "$#" -ne 1 ]]; then
  echo "Usage: run_test.sh <module-dir>" >&2
  exit 2
fi
module_dir="$1"

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"
nested_bazel_setup "rules_scala_standalone_root_build_output_base"
cd "${NESTED_BAZEL_WORKSPACE}/${module_dir}"

if ! output="$(nested_bazel_run build //... 2>&1)"; then
  echo "${output}" >&2
  echo "bazel build //... failed in ${module_dir}" >&2
  exit 1
fi
