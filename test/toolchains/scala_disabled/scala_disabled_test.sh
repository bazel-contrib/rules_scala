#!/usr/bin/env bash
#
# Checks that a consumer module without `scala_deps.scala()` gets a
# `@rules_scala_toolchains` repo with only the toolchains it enabled.

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

nested_bazel_setup "rules_scala_scala_disabled_output_base"

# Bazel needs forward-slash native paths on Windows for the
# `local_path_override` below; `cygpath -m` emits them.
rules_scala_dir="${NESTED_BAZEL_WORKSPACE}"
if command -v cygpath >/dev/null; then
  rules_scala_dir="$(cygpath -m "${rules_scala_dir}")"
fi

scratch_module="${TEST_TMPDIR:-$(mktemp -d)}/scala_disabled_consumer"
mkdir -p "${scratch_module}"
cp "${NESTED_BAZEL_WORKSPACE}/.bazelversion" "${scratch_module}/"
touch "${scratch_module}/BUILD"

cat >"${scratch_module}/MODULE.bazel" <<EOF
module(name = "scala_disabled_consumer", version = "0.0.0")

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

scala_deps = use_extension(
    "@rules_scala//scala/extensions:deps.bzl",
    "scala_deps",
)
scala_deps.junit()
use_repo(scala_deps, "rules_scala_toolchains")
EOF

cd "${scratch_module}"

if ! targets="$(nested_bazel_run query @rules_scala_toolchains//... 2>&1)"; then
  echo "Querying @rules_scala_toolchains failed:" >&2
  echo "${targets}" >&2
  exit 1
fi

if ! grep -q '^@rules_scala_toolchains//testing:' <<<"${targets}"; then
  echo "Expected the JUnit toolchain in @rules_scala_toolchains//testing:" >&2
  echo "${targets}" >&2
  exit 1
fi

if grep '^@rules_scala_toolchains//scala:' <<<"${targets}"; then
  echo "Found the default Scala toolchain without scala_deps.scala()." >&2
  exit 1
fi
