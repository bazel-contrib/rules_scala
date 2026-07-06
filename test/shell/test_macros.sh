#!/usr/bin/env bash

set -euo pipefail

# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

incorrect_macro_user_does_not_build() {
  (! bazel build //test/macros:incorrect-macro-user) 2>&1 |
    grep --fixed-strings 'Build failure during macro expansion. You may have declared a target containing a macro as a `scala_library` target instead of a `scala_macro_library` target'
}

correct_macro_user_builds() {
  bazel build //test/macros:correct-macro-user
}

macros_can_have_dependencies() {
  bazel build //test/macros:macro-with-dependencies-user
}

# Regression tests for https://github.com/bazel-contrib/rules_scala/issues/1819
macro_export_user_builds() {
  local scala_version="$1"
  bazel build "--repo_env=SCALA_VERSION=${scala_version}" //test/macros:macro-export-user
}

scala_macro_library_does_not_build_ijar() {
  local scala_version="$1"
  local ijar_path="bazel-bin/test/macros/correct-macro-ijar.jar"

  rm -f "${ijar_path}"
  bazel build "--repo_env=SCALA_VERSION=${scala_version}" //test/macros:correct-macro
  if [[ -f "${ijar_path}" ]]; then
    echo "scala_macro_library should not produce an ijar on Scala ${scala_version}"
    exit 1
  fi
}

$runner incorrect_macro_user_does_not_build
$runner correct_macro_user_builds
$runner macros_can_have_dependencies

for scala_version in 2.12.21 2.13.18; do
  $runner macro_export_user_builds "$scala_version"
  $runner scala_macro_library_does_not_build_ijar "$scala_version"
done
