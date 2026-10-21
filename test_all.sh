#!/usr/bin/env bash

set -euo pipefail

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
"${dir}"/test_lint.sh
"${dir}"/test_rules_scala.sh
"${dir}"/test_version.sh
"${dir}"/test_dependency_versions.sh
bazel test --skip_incompatible_explicit_targets \
  //test/reproducibility:build_is_identical_test
#"${dir}"/test_intellij_aspect.sh
"${dir}"/test_examples.sh
bazel test --test_output=errors -- //test_thirdparty_version/...
"${dir}"/dt_patches/dt_patch_test.sh
