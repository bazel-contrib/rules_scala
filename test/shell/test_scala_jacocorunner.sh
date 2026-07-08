# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_scala_jacocorunner_from_scala_toolchain_passes() {
  bazel coverage --extra_toolchains="//manual_test/scala_test_jacocorunner:passing_scala_toolchain" //manual_test/scala_test_jacocorunner:empty_test
}

#Jacocoa support not implemented for windows just yet
if ! is_windows; then
  $runner test_scala_jacocorunner_from_scala_toolchain_passes
fi
