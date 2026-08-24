#!/usr/bin/env bash
#
# Runs a nested `bazel <command>` (build/test/coverage) of a target, asserts it
# fails (or, with --expect-success, succeeds), and that the combined output
# contains every expected message and none of the rejected messages.
#
# The nested `bazel` invocation (and the rationale for it) lives in the shared
# nested_bazel.sh helper this script sources.
#
# Usage:
#   expect_build_failure.sh --target <label> --lane <0|1> \
#       [--command <build|test|coverage>] \
#       [--expect-success] \
#       [--env <KEY=VALUE>]... \
#       [--bazel-arg <flag>]... \
#       [--bazel-arg-file <path>]... \
#       [--expect-file <path>]... \
#       [--reject-file <path>]...
#
#   --target          the label to act on.
#   --lane            which of the 2 shared nested output bases to use (see
#                      nested_bazel_setup); the caller macro derives this from
#                      hash(name) % 2.
#   --command         the bazel subcommand to run; defaults to `build`.
#   --expect-success  assert the invocation succeeds; by default it must fail.
#   --env             KEY=VALUE exported into the nested `bazel` client env before
#                     the invocation (e.g. to feed a target's `env_inherit`);
#                     repeatable.
#   --bazel-arg       extra option forwarded to the nested `bazel <command>` (e.g.
#                     `--repo_env=SCALA_VERSION=2.13.18` or `--extra_toolchains=...`);
#                     repeatable.
#   --bazel-arg-file  like --bazel-arg, but the (newline-stripped) contents of the
#                     given file are the flag. Use this for a flag whose value
#                     Bazel's `sh_test` args pipeline would mangle -- a space (see
#                     the note below) or a shell metacharacter that the Windows
#                     launcher's `bash -c` would interpret (e.g. a `--test_filter`
#                     regex with `(`/`|`/`$`); repeatable.
#   --clean-before-build  run `bazel clean` (no --expunge) against the nested
#                     output base before the real invocation. The caller
#                     (expect_build_success_test) passes this whenever it also
#                     has expect/reject files: unlike a failure, a successful
#                     action can be served from the nested output base's
#                     on-disk cache on a later run of this same test, silently
#                     skipping recompilation and so reprinting no output to
#                     check. `bazel clean` clears that without re-fetching the
#                     external repos the nested output base keeps warm.
#   --expect-file     file whose (newline-stripped) contents must appear in the
#                     output; repeatable.
#   --reject-file     file whose (newline-stripped) contents must NOT appear in the
#                     output; repeatable.
#
# Messages are passed as files rather than inline strings because Bazel subjects
# `sh_test` `args` to Bourne tokenization, which would split messages that
# contain spaces.

set -euo pipefail

# Captured before nested_bazel_setup `cd`s into the workspace, so message-file
# paths passed as runfiles-relative (e.g. via `$(rootpath ...)`) still resolve.
orig_pwd="${PWD}"

# shellcheck source=test/expect_build_failure/nested_bazel.sh
source "${TEST_SRCDIR:-${RUNFILES_DIR:-$0.runfiles}}/${TEST_WORKSPACE:-_main}/test/expect_build_failure/nested_bazel.sh"

target=""
command="build"
expect_success="false"
clean_before_build="false"
lane=""
bazel_args=()
bazel_arg_files=()
expect_files=()
reject_files=()

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --target)
      target="$2"
      shift 2
      ;;
    --command)
      command="$2"
      shift 2
      ;;
    --expect-success)
      expect_success="true"
      shift
      ;;
    --clean-before-build)
      clean_before_build="true"
      shift
      ;;
    --lane)
      lane="$2"
      shift 2
      ;;
    --env)
      # Exported here so it reaches the nested `bazel` client (nested_bazel_run
      # only prepends HOME, preserving the rest of the environment).
      export "${2?--env requires KEY=VALUE}"
      shift 2
      ;;
    --bazel-arg)
      bazel_args+=("$2")
      shift 2
      ;;
    --bazel-arg-file)
      bazel_arg_files+=("$2")
      shift 2
      ;;
    --expect-file)
      expect_files+=("$2")
      shift 2
      ;;
    --reject-file)
      reject_files+=("$2")
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if [[ -z "${target}" ]]; then
  echo "Missing required --target." >&2
  exit 2
fi

if [[ -z "${lane}" ]]; then
  echo "Missing required --lane." >&2
  exit 2
fi

# Resolves a message file path, tolerating an absolute path, a path relative to
# the original working directory (before the `cd` in nested_bazel_setup), or one
# relative to the test's runfiles root.
_resolve_message_file() {
  local file="$1"

  local candidate
  for candidate in \
    "${file}" \
    "${orig_pwd}/${file}" \
    "${TEST_SRCDIR:-}/${TEST_WORKSPACE:-}/${file}"; do
    if [[ -f "${candidate}" ]]; then
      printf '%s' "${candidate}"
      return
    fi
  done

  printf '%s' "${file}"
}

nested_bazel_setup "rules_scala_expect_build_failure_output_base_lane${lane}"

# Append file-backed flags (see --bazel-arg-file). Read here, after parsing, so
# the shell never has to carry the raw value on a command line.
for bazel_arg_file in ${bazel_arg_files[@]+"${bazel_arg_files[@]}"}; do
  resolved="$(_resolve_message_file "${bazel_arg_file}")"
  bazel_args+=("$(tr -d '\n' <"${resolved}")")
done

if [[ "${clean_before_build}" == "true" ]]; then
  nested_bazel_run clean >/dev/null 2>&1
fi

set +e
output="$(nested_bazel_run "${command}" ${bazel_args[@]+"${bazel_args[@]}"} "${target}" 2>&1)"
status=$?
set -e

if [[ "${expect_success}" == "true" && "${status}" -ne 0 ]]; then
  echo "Expected \`bazel ${command}\` of \"${target}\" to succeed, but it failed (exit ${status})." >&2
  echo "${output}" >&2
  exit 1
fi
if [[ "${expect_success}" != "true" && "${status}" -eq 0 ]]; then
  echo "Expected \`bazel ${command}\` of \"${target}\" to fail, but it succeeded." >&2
  echo "${output}" >&2
  exit 1
fi

# Checks each file in $2... against $output, failing if its (fixed-string)
# content is found and $1 is "false", or missing and $1 is "true".
_check_files() {
  local must_match="$1"
  shift

  local file resolved text matched
  for file in "$@"; do
    resolved="$(_resolve_message_file "${file}")"
    text="$(tr -d '\n' <"${resolved}")"

    if grep --quiet --fixed-strings -- "${text}" <<<"${output}"; then
      matched="true"
    else
      matched="false"
    fi
    if [[ "${matched}" == "${must_match}" ]]; then
      continue
    fi

    if [[ "${must_match}" == "true" ]]; then
      echo "Nested \`bazel ${command}\` finished as expected, but output did not contain the expected message." >&2
      echo "Expected (from ${file}): ${text}" >&2
    else
      echo "Nested \`bazel ${command}\` finished as expected, but output contained a message that should be absent." >&2
      echo "Rejected (from ${file}): ${text}" >&2
    fi
    echo "Output:" >&2
    echo "${output}" >&2
    exit 1
  done
}

_check_files true ${expect_files[@]+"${expect_files[@]}"}
_check_files false ${reject_files[@]+"${reject_files[@]}"}
