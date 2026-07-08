# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

multiple_junit_suffixes() {
  bazel test //test:JunitMultipleSuffixes

  matches=$(grep -c -e 'Discovered classes' -e 'scalarules.test.junit.JunitSuffixIT' -e 'scalarules.test.junit.JunitSuffixE2E' ./bazel-testlogs/test/JunitMultipleSuffixes/test.log)
  if [ $matches -eq 3 ]; then
    return 0
  else
    return 1
  fi
}

multiple_junit_prefixes() {
  bazel test //test:JunitMultiplePrefixes

  matches=$(grep -c -e 'Discovered classes' -e 'scalarules.test.junit.TestJunitCustomPrefix' -e 'scalarules.test.junit.OtherCustomPrefixJunit' ./bazel-testlogs/test/JunitMultiplePrefixes/test.log)
  if [ $matches -eq 3 ]; then
    return 0
  else
    return 1
  fi
}

multiple_junit_patterns() {
  bazel test //test:JunitPrefixesAndSuffixes
  matches=$(grep -c -e 'Discovered classes' -e 'scalarules.test.junit.TestJunitCustomPrefix' -e 'scalarules.test.junit.JunitSuffixE2E' ./bazel-testlogs/test/JunitPrefixesAndSuffixes/test.log)
  if [ $matches -eq 3 ]; then
    return 0
  else
    return 1
  fi
}

junit_generates_xml_logs() {
  bazel test //test:JunitTestWithDeps
  matches=$(grep -c -e "testcase name='hasCompileTimeDependencies'" -e "testcase name='hasRuntimeDependencies'" ./bazel-testlogs/test/JunitTestWithDeps/test.xml)
  if [ $matches -eq 2 ]; then
    return 0
  else
    return 1
  fi
  test -e
}

scala_junit_test_test_filter(){
  local output=$(bazel test \
    --nocache_test_results \
    --test_output=streamed \
    '--test_filter=scalarules.test.junit.FirstFilterTest#(method1|method2)$|scalarules.test.junit.SecondFilterTest#(method2|method3)$' \
    test:JunitFilterTest)
  local expected=(
      "scalarules.test.junit.FirstFilterTest#method1"
      "scalarules.test.junit.FirstFilterTest#method2"
      "scalarules.test.junit.SecondFilterTest#method2"
      "scalarules.test.junit.SecondFilterTest#method3")
  local unexpected=(
      "scalarules.test.junit.FirstFilterTest#method3"
      "scalarules.test.junit.SecondFilterTest#method1"
      "scalarules.test.junit.ThirdFilterTest#method1"
      "scalarules.test.junit.ThirdFilterTest#method2"
      "scalarules.test.junit.ThirdFilterTest#method3")
  for method in "${expected[@]}"; do
    if ! grep "$method" <<<$output; then
      echo "output:"
      echo "$output"
      echo "Expected $method in output, but was not found."
      exit 1
    fi
  done
  for method in "${unexpected[@]}"; do
    if grep "$method" <<<$output; then
      echo "output:"
      echo "$output"
      echo "Not expecting $method in output, but was found."
      exit 1
    fi
  done
}

scala_junit_test_test_filter_custom_runner(){
  bazel test \
    --nocache_test_results \
    --test_output=streamed \
    '--test_filter=scalarules.test.junit.JunitCustomRunnerTest#' \
    test:JunitCustomRunner
}

$runner multiple_junit_suffixes
$runner multiple_junit_prefixes
$runner multiple_junit_patterns
$runner junit_generates_xml_logs
$runner scala_junit_test_test_filter
$runner scala_junit_test_test_filter_custom_runner
