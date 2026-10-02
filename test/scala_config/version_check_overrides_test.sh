#!/usr/bin/env bash
#
# Checks which `overridden_artifact` sets make `scala_deps` skip the Scala
# version check. The check runs while Bazel evaluates the extension, so the test
# evaluates it in a generated consumer module.

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

start_module "3.8.3"
add_override io_bazel_rules_scala_scala_library \
  org.scala-lang:scala3-library_3:3.8.3 \
  740c79f7fc3dae2c5eef48e85f777d679a1f0f53fdbb780bf84dea0370220a61
add_override io_bazel_rules_scala_scala_compiler \
  org.scala-lang:scala3-compiler_3:3.8.3 \
  cd5e5aa54b610e37522deea19344a9d9614d5fbc9cf052de08a66ceb7c1a8974
add_override io_bazel_rules_scala_scala_interfaces \
  org.scala-lang:scala3-interfaces:3.8.3 \
  98bb43395ad33b65b7ea59ed3705fc14174b6179f4d21d561ae96ef97be563c0
add_override io_bazel_rules_scala_scala_tasty_core \
  org.scala-lang:tasty-core_3:3.8.3 \
  1c771f2416b4e455b269981a17c0804b237eed120c8807af808f192085c3e516
add_override org_scala_lang_scala3_repl \
  org.scala-lang:scala3-repl_3:3.8.3 \
  d00e3ab80898f3f0b221535f251f51b21b9d4db50539e6ceec54183a13ae7a01
expect_mismatch_error "every Scala 3 jar but scala-library"
add_override io_bazel_rules_scala_scala_library_2 \
  org.scala-lang:scala-library:3.8.3 \
  8b5164c4be2d7a86635966b419a08b393e58b3c7bc0cafb502e0f34248722b4e
expect_success "every Scala 3 jar"
