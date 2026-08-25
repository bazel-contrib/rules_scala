#!/usr/bin/env bash
# Builds //test/fetch_sources:fetch_sources and checks whether Maven source
# jars got fetched, based on the BAZEL_JVM_FETCH_SOURCES env var. The
# repository rule declares that var in `environ`, so Bazel re-fetches
# whenever it changes; the test instantiations can safely share one nested
# output base.
#
# Usage:
#   fetch_sources_test.sh [--env-value=<value>] --expect-exists=<true|false>

set -euo pipefail

ENV_VALUE=""
EXPECT_EXISTS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-value=*)
      ENV_VALUE="${1#*=}"
      shift
      ;;
    --expect-exists=*)
      EXPECT_EXISTS="${1#*=}"
      shift
      ;;
    *)
      echo "Unexpected argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "${EXPECT_EXISTS}" ]]; then
  echo "Usage: fetch_sources_test.sh [--env-value=<value>] --expect-exists=<true|false>" >&2
  exit 1
fi

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"
nested_bazel_setup "rules_scala_fetch_sources_test_output_base"

if [[ -n "${ENV_VALUE}" ]]; then
  export BAZEL_JVM_FETCH_SOURCES="${ENV_VALUE}"
fi

target="//test/fetch_sources:fetch_sources"
if ! build_output="$(nested_bazel_run build "${target}" 2>&1)"; then
  echo "Expected build of ${target} to succeed, but it failed." >&2
  echo "${build_output}" >&2
  exit 1
fi

# The main jar is downloaded unconditionally, so resolve its (execroot-relative)
# path and find the repo's directory on disk from it -- resolving the source
# jar's own label the same way would fail outright (not just report absence)
# on the runs where it was never fetched.
#
# cquery, not plain query: nested_bazel_run always passes --symlink_prefix
# (needed for build/test/run), which plain `query` rejects outright.
main_jar_target="@com_google_guava_guava_21_0//:guava-21.0.jar"
main_jar_relpath="$(nested_bazel_run cquery --output=files "${main_jar_target}")"
execution_root="$(nested_bazel_run info execution_root)"
srcjar_path="$(dirname "${execution_root}/${main_jar_relpath}")/guava-21.0-src.jar"

if [[ "${EXPECT_EXISTS}" == "true" ]]; then
  if [[ ! -f "${srcjar_path}" ]]; then
    echo "File ${srcjar_path} does not exist but we expect it to exist." >&2
    exit 1
  fi
else
  if [[ -f "${srcjar_path}" ]]; then
    echo "File ${srcjar_path} exists but we expect no source jars." >&2
    exit 1
  fi
fi
