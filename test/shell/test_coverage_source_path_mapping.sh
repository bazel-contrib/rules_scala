# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

# Default to 2.12.21 for `diff` tests because other versions change the output.
SCALA_VERSION="${SCALA_VERSION:-2.12.21}"

coverage_dat() {
    echo "$(bazel info bazel-testlogs)/test/coverage_source_path_mapping/test-source-path-mapping/coverage.dat"
}

run_coverage() {
    bazel coverage \
        --repo_env="SCALA_VERSION=${SCALA_VERSION}" \
        --instrumentation_filter='^//test/coverage_source_path_mapping[:/]' \
        //test/coverage_source_path_mapping:test-source-path-mapping
}

# Prints the LCOV record for a source file, without the surrounding records.
coverage_record_for() {
    awk -v src="SF:$1" \
        '$0 == src {found = 1} found {print} $0 == "end_of_record" {found = 0}' \
        "$2"
}

assert_source_has_hit_lines() {
    local source="test/coverage_source_path_mapping/$1"
    local dat="$2"
    local record

    record="$(coverage_record_for "$source" "$dat")"

    if [[ -z "$record" ]]; then
        fail "no coverage record for ${source} in ${dat}"
    elif ! grep -qE '^DA:[0-9]+,[1-9]' <<<"$record"; then
        fail "no covered lines reported for ${source}:" "$record"
    elif ! grep -qE '^LH:[1-9]' <<<"$record"; then
        fail "zero hit lines reported for ${source}:" "$record"
    fi
}

test_coverage_when_source_path_does_not_end_with_package_path() {
    run_coverage
    diff test/coverage_source_path_mapping/expected-coverage.dat "$(coverage_dat)"
}

# Regression test for https://github.com/bazel-contrib/rules_scala/issues/1101. Without an
# explicit source path mapping in `-paths-for-coverage.txt`, `JacocoLCOVFormatter` can only
# match the class-derived path `<package>/<SourceFileName>` against the tail of each source
# path. That succeeds for a Maven-style layout and fails for these sources, which used to
# be left out of the report entirely.
test_coverage_reports_hit_lines_for_every_instrumented_source() {
    local dat

    run_coverage
    dat="$(coverage_dat)"

    assert_source_has_hit_lines AlsoMapped.scala "$dat" &&
        assert_source_has_hit_lines Mapped.scala "$dat"
}

$runner test_coverage_when_source_path_does_not_end_with_package_path
$runner test_coverage_reports_hit_lines_for_every_instrumented_source
