#!/usr/bin/env bash
#
# Overriding an artifact unrelated to the Scala version (here ScalaTest) must
# keep the Scala version check on: with `scala_version = "2.13.14"` and no
# repository for it, `scala_deps` must fail instead of fetching the default
# 2.13 jars under the 2.13.14 name.
#
# The check runs while Bazel evaluates the `scala_deps` extension of a consumer
# module, so the test synthesizes that module in the test's tmpdir and evaluates
# the extension with the nested `bazel` from nested_bazel.sh.

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

nested_bazel_setup "rules_scala_unrelated_override_output_base"

# Bazel needs forward-slash native paths on Windows for the
# `local_path_override` below; `cygpath -m` emits them.
rules_scala_dir="${NESTED_BAZEL_WORKSPACE}"
if command -v cygpath >/dev/null; then
  rules_scala_dir="$(cygpath -m "${rules_scala_dir}")"
fi

scratch_module="${TEST_TMPDIR:-$(mktemp -d)}/unrelated_override_consumer"
mkdir -p "${scratch_module}"
cp "${NESTED_BAZEL_WORKSPACE}/.bazelversion" "${scratch_module}/"
touch "${scratch_module}/BUILD"

cat >"${scratch_module}/MODULE.bazel" <<EOF
module(name = "unrelated_override_consumer", version = "0.0.0")

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

scala_config = use_extension(
    "@rules_scala//scala/extensions:config.bzl",
    "scala_config",
)
scala_config.settings(scala_version = "2.13.14")

scala_deps = use_extension(
    "@rules_scala//scala/extensions:deps.bzl",
    "scala_deps",
)
scala_deps.scala()
scala_deps.overridden_artifact(
    name = "io_bazel_rules_scala_scalatest",
    artifact = "org.scalatest:scalatest_2.13:3.2.19",
    sha256 = "c37d97f16172d45b2aef0cebbe59dd2174b7d1ff2c2f272516707cf923015a52",
)
EOF

cd "${scratch_module}"

expected="Scala config (2.13.14) version does not match repository version"
if output="$(nested_bazel_run mod show_extension \
  @rules_scala//scala/extensions:deps.bzl%scala_deps 2>&1)"; then
  echo "Expected scala_deps to fail with \"${expected}\", but it succeeded:" >&2
  echo "${output}" >&2
  exit 1
fi

if ! grep --quiet --fixed-strings "${expected}" <<<"${output}"; then
  echo "scala_deps failed, but without \"${expected}\":" >&2
  echo "${output}" >&2
  exit 1
fi
