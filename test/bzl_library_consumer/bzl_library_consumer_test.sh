#!/usr/bin/env bash
#
# Builds `starlark_doc_extract` for a macro in a consumer module. The macro
# loads rules_scala files, and its `bzl_library` depends on the rules_scala
# targets that the consumer's gazelle guesses for these files.

set -euo pipefail

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

nested_bazel_setup "rules_scala_bzl_library_consumer_output_base"

# Bazel needs forward-slash native paths on Windows for the
# `local_path_override` below; `cygpath -m` emits them.
rules_scala_dir="${NESTED_BAZEL_WORKSPACE}"
if command -v cygpath >/dev/null; then
  rules_scala_dir="$(cygpath -m "${rules_scala_dir}")"
fi

scratch_module="${TEST_TMPDIR:-$(mktemp -d)}/bzl_library_consumer"
mkdir -p "${scratch_module}"
cp "${NESTED_BAZEL_WORKSPACE}/.bazelversion" "${scratch_module}/"

cat >"${scratch_module}/MODULE.bazel" <<EOF
module(name = "bzl_library_consumer", version = "0.0.0")

bazel_dep(name = "bazel_skylib", version = "1.8.0")
bazel_dep(name = "rules_scala")
local_path_override(
    module_name = "rules_scala",
    path = "${rules_scala_dir}",
)
EOF

cat >"${scratch_module}/macros.bzl" <<'EOF'
"""Macros of the consumer module."""

load("@rules_scala//scala:advanced_usage/scala.bzl", "make_scala_library")
load("@rules_scala//scala:scala.bzl", "scala_library")

def consumer_library(name, **kwargs):
    """Declares a `scala_library`.

    Args:
        name: the target name
        **kwargs: other `scala_library` attributes
    """
    scala_library(name = name, **kwargs)

consumer_custom_library = make_scala_library()
EOF

cat >"${scratch_module}/BUILD" <<'EOF'
load("@bazel_skylib//:bzl_library.bzl", "bzl_library")

bzl_library(
    name = "macros",
    srcs = ["macros.bzl"],
    deps = [
        "@rules_scala//scala:advanced_usage/scala",
        "@rules_scala//scala:scala",
    ],
)

starlark_doc_extract(
    name = "macros_doc",
    src = "macros.bzl",
    deps = [":macros"],
)
EOF

cd "${scratch_module}"

if ! build_output="$(nested_bazel_run build //:macros_doc 2>&1)"; then
  echo "starlark_doc_extract for a consumer macro that loads rules_scala" \
    "files failed:" >&2
  echo "${build_output}" >&2
  exit 1
fi
