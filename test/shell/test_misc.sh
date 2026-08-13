# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_override_javabin() {
  # set the JAVABIN to nonsense
  JAVABIN=/etc/basdf action_should_fail run test:ScalaBinary
}

xmllint_test() {
  find -L ./bazel-testlogs -iname "*.xml" | xargs -n1 xmllint > /dev/null
}

if  ! is_windows; then
  #javabin only affects wrapper scripts for linux
  $runner test_override_javabin
fi
$runner xmllint_test
