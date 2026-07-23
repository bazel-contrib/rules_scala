# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
runner=$(get_test_runner "${1:-local}")

test_resources() {
  RESOURCE_NAME="resource.txt"
  TARGET=$1
  OUTPUT_JAR="bazel-bin/test/src/main/scala/scalarules/test/resources/$TARGET.jar"
  FULL_TARGET="test/src/main/scala/scalarules/test/resources/$TARGET.jar"
  bazel build $FULL_TARGET
  jar tf $OUTPUT_JAR | grep $RESOURCE_NAME
}

scala_library_jar_without_srcs_must_include_direct_file_resources(){
  test_resources "noSrcsWithDirectFileResources"
}

scala_library_jar_without_srcs_must_include_filegroup_resources(){
  test_resources "noSrcsWithFilegroupResources"
}

$runner scala_library_jar_without_srcs_must_include_direct_file_resources
$runner scala_library_jar_without_srcs_must_include_filegroup_resources
