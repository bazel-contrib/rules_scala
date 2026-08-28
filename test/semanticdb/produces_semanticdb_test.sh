#!/usr/bin/env bash
#
# Builds semantic_provider_vars_all under a given toolchain and Scala epoch
# (Scala's own EPOCH.MAJOR.MINOR versioning, e.g. 2 vs 3), then checks the
# SemanticdbInfo provider values (via the build-generated shell script) and
# the resulting .semanticdb files: present under the target root, and bundled
# into (or absent from) all_lib.jar depending on the toolchain's bundle
# setting.
#
# Usage:
#   produces_semanticdb_test.sh --toolchain=<label> --is-bundle=0|1 --scala-epoch=2|3 [extra-bazel-arg]...

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

toolchain=""
is_bundle=""
scala_epoch=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --toolchain=*)
      toolchain="${1#*=}"
      shift
      ;;
    --is-bundle=*)
      is_bundle="${1#*=}"
      shift
      ;;
    --scala-epoch=*)
      scala_epoch="${1#*=}"
      shift
      ;;
    *)
      break
      ;;
  esac
done
extra_args=("$@")

if [[ -z "${toolchain}" || -z "${is_bundle}" || -z "${scala_epoch}" ]]; then
  echo "Usage: produces_semanticdb_test.sh --toolchain=<label> --is-bundle=0|1 --scala-epoch=2|3 [extra-bazel-arg]..." >&2
  exit 2
fi

nested_bazel_setup "rules_scala_semanticdb_output_base"

# "${extra_args[@]}" errors under `set -u` on bash 3.2 (macOS's system bash)
# when extra_args is empty (the scala2 case passes no extra args), so it's
# only expanded when non-empty.
build_args=("--extra_toolchains=${toolchain}")
if [[ "${#extra_args[@]}" -gt 0 ]]; then
  build_args+=("${extra_args[@]}")
fi

if ! build_output="$(nested_bazel_run build "${build_args[@]}" //test/semanticdb:semantic_provider_vars_all 2>&1)"; then
  echo "Expected build of //test/semanticdb:semantic_provider_vars_all to succeed." >&2
  echo "${build_output}" >&2
  exit 1
fi

bazel_bin="$(nested_bazel_run info "${build_args[@]}" bazel-bin 2>/dev/null)"
execution_root="$(nested_bazel_run info "${build_args[@]}" execution_root 2>/dev/null)"

# The four checks below read fields of the SemanticdbInfo provider
# (scala/semanticdb_provider.bzl, populated by scala/private/phases/
# phase_semanticdb.bzl), surfaced as shell variables by this build-generated
# script -- read here rather than in Starlark, since the assertions run in
# this sh_test, not in an aspect.
# shellcheck disable=SC1090,SC1091
source "${bazel_bin}/test/semanticdb/semantic_provider_vars_all.sh"

if [[ "${semanticdb_enabled}" -ne 1 ]]; then
  echo "Error: SemanticdbInfo.semanticdb_enabled=${semanticdb_enabled}, expected 1 (the toolchain under test enables semanticdb)" >&2
  exit 1
fi

if [[ "${semanticdb_is_bundled}" -ne "${is_bundle}" ]]; then
  echo "Error: SemanticdbInfo.is_bundled_in_jar=${semanticdb_is_bundled}, expected ${is_bundle} to match the --is-bundle argument" >&2
  exit 1
fi

if [[ -z "${semanticdb_target_root}" ]]; then
  echo "Error: SemanticdbInfo.target_root is empty, expected a non-empty path" >&2
  exit 1
fi

if [[ "${scala_epoch}" == 3 && -n "${semanticdb_pluginjarpath}" ]]; then
  echo "Error: SemanticdbInfo.plugin_jar=${semanticdb_pluginjarpath}, expected empty for Scala 3 (semanticdb is built into scalac there, no separate plugin)" >&2
  exit 1
fi
if [[ "${scala_epoch}" == 2 && -z "${semanticdb_pluginjarpath}" ]]; then
  echo "Error: SemanticdbInfo.plugin_jar is empty, expected a path for Scala 2 (the semanticdb-scalac plugin jar)" >&2
  exit 1
fi

semanticdb_path="${execution_root}/${semanticdb_target_root}/META-INF/semanticdb/test/semanticdb/"
for f in A.scala.semanticdb B.scala.semanticdb; do
  if [[ ! -f "${semanticdb_path}${f}" ]]; then
    echo "Error: Expected Semanticdb file not found: ${semanticdb_path}${f}" >&2
    exit 1
  fi
done

jar="${bazel_bin}/test/semanticdb/all_lib.jar"
jar_listing="$(jar tf "${jar}")"
for f in A.scala.semanticdb B.scala.semanticdb; do
  if printf '%s\n' "${jar_listing}" | grep -qF "${f}"; then
    found=1
  else
    found=0
  fi
  if [[ "${is_bundle}" -eq 1 && "${found}" -eq 0 ]]; then
    echo "Error: SemanticDB output not included in jar: ${jar}" >&2
    exit 1
  fi
  if [[ "${is_bundle}" -eq 0 && "${found}" -eq 1 ]]; then
    echo "Error: SemanticDB output erroneously included in jar: ${jar}" >&2
    exit 1
  fi
done
