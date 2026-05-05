# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
. "${dir}"/test_scalafmt_helper.sh
runner=$(get_test_runner "${1:-local}")

cd test_cross_build

function test_cross_build() {
  bazel test //...
}

function test_cross_build_default_2x() {
  # Verify cross-major-version compilation when the default is Scala 2.x and
  # targets use scala_version to select Scala 3.x. Without the select-based
  # common_toolchain_deps fix, the reporter java_library compiles Scala 3
  # sources against Scala 2 compiler JARs (wrong toolchain resolved in exec
  # config), failing with "symbol not found dotty.tools.dotc.*".
  #
  # since_3_1 is the target that exercises the fix (default 2.x -> target 3.x).
  # scala_2_13 and scala_2_12 are sanity checks for same-major cross-minor.
  bazel build \
    --repo_env=SCALA_VERSION=2.13.18 \
    //version_specific:since_3_1 \
    //version_specific:scala_2_13 \
    //version_specific:scala_2_12
}

function test_scalafmt() {
  bazel build //scalafmt/...

  run_formatting scalafmt binary2 binary2
  run_formatting scalafmt binary3 binary3
  run_formatting scalafmt library2 library2
  run_formatting scalafmt library3 library3
  run_formatting scalafmt test2 test2
  run_formatting scalafmt test3 test3
}

$runner test_cross_build
$runner test_cross_build_default_2x
$runner test_scalafmt

# `bazel shutdown` used to be in `test_cross_build`, after a `bazel clean`.
# However, the protobuf library tends to rebuild frequently. Not cleaning and
# postponing the shutdown to the end of the script helps avoid rebuilding as
# often, speeding up the tests. It also potentially speeds up debugging by
# preserving the workspace state when a test fails.
bazel shutdown
