# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_disappearing_class() {
  tmp=$(mktemp -d -t test_disappearing_class-XXXXXXXXXX)
  out=$tmp/out
  cache=$tmp/cache
  git checkout test_expect_failure/disappearing_class/ClassProvider.scala
  bazel --output_base=$out build --disk_cache=$cache test_expect_failure/disappearing_class:uses_class
  echo -e "package scalarules.test\n\nobject BackgroundNoise{}" > test_expect_failure/disappearing_class/ClassProvider.scala
  set +e
  bazel --output_base=$out build --disk_cache=$cache test_expect_failure/disappearing_class:uses_class
  RET=$?
  git checkout test_expect_failure/disappearing_class/ClassProvider.scala
  rm -rf $tmp
  if [ $RET -eq 0 ]; then
    echo "Class caching at play. This should fail"
    exit 1
  fi
  set -e
}

test_repl() {
  local query_results=$(bazel query 'kind(scala_repl, //test/...)')

  # Leave unquoted so the newline-separated targets word-split into separate
  # build args; `//$'\r'` strips the carriage returns Bazel emits on Windows so
  # bash can parse the args correctly there.
  bazel build ${query_results//$'\r'}
  echo "import scalarules.test._; HelloLib.printMessage(\"foo\")" | bazel-bin/test/HelloLibRepl -Xnojline | grep "foo java" &&
  echo "import scalarules.test._; TestUtil.foo" | bazel-bin/test/HelloLibTestRepl -Xnojline | grep "bar" &&
  echo "import scalarules.test._; ScalaLibBinary.main(Array())" | bazel-bin/test/ScalaLibBinaryRepl -Xnojline | grep "A hui hou" &&
  echo "import scalarules.test._; ResourcesStripScalaBinary.main(Array())" | bazel-bin/test/ResourcesStripScalaBinaryRepl -Xnojline | grep "More Hello"
  echo "import scalarules.test._; A.main(Array())" | bazel-bin/test/ReplWithSources -Xnojline | grep "4 8 15"
}

test_benchmark_jmh() {
  RES=$(bazel run -- test/jmh:test_benchmark -i1 -f1 -wi 1)
  if [ $? -ne 0 ]; then
    exit 1
  fi
  if [[ $RES != *Result*Benchmark* ]]; then
    echo "Benchmark did not produce expected output:\n$RES"
    exit 1
  fi

  exit 0
}

scala_test_test_filters() {
    # test package wildcard (both)
    local output=$(bazel test \
                         --cache_test_results=no \
                         --test_output streamed \
                         --test_filter scalarules.test.* \
                         test:TestFilterTests)
    if [[ $output != *"tests a"* || $output != *"tests b"* ]]; then
        echo "Should have contained test output from both test filter test a and b"
        exit 1
    fi
    # test just one
    local output=$(bazel test \
                         --cache_test_results=no \
                         --test_output streamed \
                         --test_filter scalarules.test.TestFilterTestA \
                         test:TestFilterTests)
    if [[ $output != *"tests a"* || $output == *"tests b"* ]]; then
        echo "Should have only contained test output from test filter test a"
        exit 1
    fi
}

test_multi_service_manifest() {
  deploy_jar='ScalaBinary_with_service_manifest_srcs_deploy.jar'
  meta_file='META-INF/services/org.apache.beam.sdk.io.FileSystemRegistrar'
  bazel build test:$deploy_jar
  unzip -p bazel-bin/test/$deploy_jar $meta_file > service_manifest.txt
  diff --strip-trailing-cr service_manifest.txt test/example_jars/expected_service_manifest.txt
  RESPONSE_CODE=$?
  rm service_manifest.txt
  exit $RESPONSE_CODE
}

test_override_javabin() {
  # set the JAVABIN to nonsense
  JAVABIN=/etc/basdf action_should_fail run test:ScalaBinary
}

xmllint_test() {
  find -L ./bazel-testlogs -iname "*.xml" | xargs -n1 xmllint > /dev/null
}

$runner test_disappearing_class
$runner test_repl
$runner test_benchmark_jmh
$runner scala_test_test_filters
$runner test_multi_service_manifest

if  ! is_windows; then
  #javabin only affects wrapper scripts for linux
  $runner test_override_javabin
fi
$runner xmllint_test
