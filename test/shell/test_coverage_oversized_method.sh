# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

TARGET='//test/coverage_oversized_method:test-oversized-method'
SKIP_TOOLCHAIN='//test/toolchains:coverage_skip_oversized_methods'
WARNING='JacocoInstrumenter: skipping /coverage_oversized_method/OversizedMethod.class'

_coverage_report() {
    printf '%s' \
      "$(bazel info bazel-testlogs)/test/coverage_oversized_method/test-oversized-method/coverage.dat"
}

test_oversized_method_passes_without_coverage() {
    bazel test "$TARGET"
}

test_oversized_method_fails_coverage_by_default() {
    action_should_fail_with_message 'MethodTooLargeException' coverage "$TARGET"
}

test_oversized_method_skipped_when_enabled() {
    local output=''

    output="$(bazel coverage --extra_toolchains="$SKIP_TOOLCHAIN" "$TARGET" 2>&1)"

    if [[ "$output" != *"$WARNING"* ]]; then
      echo "$output"
      fail "\"bazel coverage\" should have warned about the skipped class:" \
        "Expected: \"${WARNING}\""
    fi

    local report="$(_coverage_report)"

    if ! grep -q 'SF:test/coverage_oversized_method/SmallClass.scala' "$report"; then
      cat "$report"
      fail "${report} should contain coverage for SmallClass.scala."
    fi

    if grep -q 'OversizedMethod' "$report"; then
      cat "$report"
      fail "${report} should not mention the skipped OversizedMethod class."
    fi
}

$runner test_oversized_method_passes_without_coverage
$runner test_oversized_method_fails_coverage_by_default
$runner test_oversized_method_skipped_when_enabled
