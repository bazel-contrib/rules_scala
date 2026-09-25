#!/usr/bin/env bash
#
# Which `overridden_artifact` sets skip the Scala version check. With a
# `scala_version` that has no repository, `scala_deps` must fail until the
# library, the compiler and, on Scala 2, scala-reflect are all overridden (a
# default scala-reflect next to an overridden compiler crashes scalac with a
# NoSuchMethodError). Overriding an unrelated artifact such as ScalaTest must
# keep the check on.
#
# The check runs while Bazel evaluates the `scala_deps` extension of a consumer
# module, so the test synthesizes that module in the test's tmpdir and evaluates
# the extension with the nested `bazel` from nested_bazel.sh.

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

nested_bazel_setup "rules_scala_version_check_overrides_output_base"

# Bazel needs forward-slash native paths on Windows for the
# `local_path_override` below; `cygpath -m` emits them.
rules_scala_dir="${NESTED_BAZEL_WORKSPACE}"
if command -v cygpath >/dev/null; then
  rules_scala_dir="$(cygpath -m "${rules_scala_dir}")"
fi

scratch_module="${TEST_TMPDIR:-$(mktemp -d)}/version_check_consumer"
mkdir -p "${scratch_module}"
cp "${NESTED_BAZEL_WORKSPACE}/.bazelversion" "${scratch_module}/"
touch "${scratch_module}/BUILD"
cd "${scratch_module}"

scala_version=""

# $1: the `scala_version` to configure; starts a module with no overrides.
start_module() {
  scala_version="$1"
  cat >MODULE.bazel <<EOF
module(name = "version_check_consumer", version = "0.0.0")

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
scala_config.settings(scala_version = "${scala_version}")

scala_deps = use_extension(
    "@rules_scala//scala/extensions:deps.bzl",
    "scala_deps",
)
scala_deps.scala()
EOF
}

# Args: repository name, Maven coordinates, sha256.
add_override() {
  cat >>MODULE.bazel <<EOF
scala_deps.overridden_artifact(
    name = "$1",
    artifact = "$2",
    sha256 = "$3",
)
EOF
}

evaluate_scala_deps() {
  nested_bazel_run mod show_extension \
    @rules_scala//scala/extensions:deps.bzl%scala_deps 2>&1
}

# $1: which overrides the module carries, for the failure message.
expect_mismatch_error() {
  local expected="Scala config (${scala_version}) version does not match repository version"
  local output
  if output="$(evaluate_scala_deps)"; then
    echo "Expected scala_deps to fail with \"${expected}\" with $1" \
      "overridden, but it succeeded:" >&2
    echo "${output}" >&2
    exit 1
  fi
  if ! grep --quiet --fixed-strings "${expected}" <<<"${output}"; then
    echo "scala_deps failed with $1 overridden, but without" \
      "\"${expected}\":" >&2
    echo "${output}" >&2
    exit 1
  fi
}

# $1: which overrides the module carries, for the failure message.
expect_success() {
  local output
  if ! output="$(evaluate_scala_deps)"; then
    echo "Expected scala_deps to succeed with $1 overridden for" \
      "${scala_version}, but it failed:" >&2
    echo "${output}" >&2
    exit 1
  fi
}

start_module "2.13.14"
add_override io_bazel_rules_scala_scalatest \
  org.scalatest:scalatest_2.13:3.2.19 \
  c37d97f16172d45b2aef0cebbe59dd2174b7d1ff2c2f272516707cf923015a52
expect_mismatch_error "only ScalaTest"
add_override io_bazel_rules_scala_scala_library \
  org.scala-lang:scala-library:2.13.14 \
  43e0ca1583df1966eaf02f0fbddcfb3784b995dd06bfc907209347758ce4b7e3
expect_mismatch_error "ScalaTest and the library"
add_override io_bazel_rules_scala_scala_compiler \
  org.scala-lang:scala-compiler:2.13.14 \
  17b7e1dd95900420816a3bc2788c8c7358c2a3c42899765a5c463a46bfa569a6
expect_mismatch_error "ScalaTest, the library and the compiler"
add_override io_bazel_rules_scala_scala_reflect \
  org.scala-lang:scala-reflect:2.13.14 \
  8846baaa8cf43b1b19725ab737abff145ca58d14a4d02e75d71ca8f7ca5f2926
expect_success "ScalaTest, the library, the compiler and scala-reflect"

start_module "3.3.4"
add_override io_bazel_rules_scala_scala_library \
  org.scala-lang:scala3-library_3:3.3.4 \
  d95184acfcd814da2e051378e4962c653f4b468f4086452ab427af030482bd3c
expect_mismatch_error "the library"
add_override io_bazel_rules_scala_scala_compiler \
  org.scala-lang:scala3-compiler_3:3.3.4 \
  2cca65fdb92e2cc393786cae61b4f7bcb9032ad4be61f9cebae1dca72997e52f
expect_success "the library and the compiler"
