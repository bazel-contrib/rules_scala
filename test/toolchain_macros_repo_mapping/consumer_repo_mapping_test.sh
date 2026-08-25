#!/usr/bin/env bash
#
# Regression test: toolchain setup macros emit `@rules_scala_config` labels
# that must resolve in rules_scala's own repo mapping, not the consumer's. A
# consumer module that does NOT `use_repo(scala_config, "rules_scala_config")`
# must still be able to instantiate `setup_scala_testing_toolchain`.
#
# The signal only exists under a consumer repo mapping (in-repo, plain strings
# and `Label()` resolve identically), so the test synthesizes a consumer module
# in the test's tmpdir and builds it with the nested `bazel` from the shared
# nested_bazel.sh helper this script sources.

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

nested_bazel_setup "rules_scala_toolchain_macros_repo_mapping_output_base"

if nested_bazel_run version 2>/dev/null | grep --quiet '^Build label: 6\.'; then
  echo "Skipping: consumer modules require bzlmod, not supported on Bazel 6."
  exit 0
fi

# Bazel needs forward-slash native paths on Windows for the
# `local_path_override` below; `cygpath -m` emits them.
rules_scala_dir="${NESTED_BAZEL_WORKSPACE}"
if command -v cygpath >/dev/null; then
  rules_scala_dir="$(cygpath -m "${rules_scala_dir}")"
fi

scratch_module="${TEST_TMPDIR:-$(mktemp -d)}/consumer_without_config_repo"
mkdir -p "${scratch_module}"

# Pin the nested bazel to the workspace's version; without a .bazelversion in
# the scratch module, bazelisk would fall back to its own default.
cp "${NESTED_BAZEL_WORKSPACE}/.bazelversion" "${scratch_module}/"

# The consumer module: uses rules_scala, does NOT `use_repo(scala_config,
# "rules_scala_config")`.
cat >"${scratch_module}/MODULE.bazel" <<EOF
module(name = "consumer_without_config_repo", version = "0.0.0")

bazel_dep(name = "rules_scala")
local_path_override(
    module_name = "rules_scala",
    path = "${rules_scala_dir}",
)

bazel_dep(name = "latest_dependencies")
local_path_override(
    module_name = "latest_dependencies",
    path = "${rules_scala_dir}/deps/latest",
)
EOF

cat >"${scratch_module}/BUILD" <<'EOF'
load("@rules_scala//testing:testing.bzl", "setup_scala_testing_toolchain")

setup_scala_testing_toolchain(
    name = "testing_toolchains",
)
EOF

cd "${scratch_module}"

if ! build_output="$(nested_bazel_run build //:testing_toolchains 2>&1)"; then
  echo "Analyzing setup_scala_testing_toolchain from a consumer module without" \
    "use_repo(scala_config, \"rules_scala_config\") failed:" >&2
  echo "${build_output}" >&2
  exit 1
fi
