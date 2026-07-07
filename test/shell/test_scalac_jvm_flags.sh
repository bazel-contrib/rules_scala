# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

test_scalac_jvm_flags_on_target_overrides_toolchain_passes() {
  bazel build --extra_toolchains="//manual_test/scalac_jvm_opts:failing_scala_toolchain" //manual_test/scalac_jvm_opts:empty_overriding_build
}

test_scalac_jvm_flags_from_scala_toolchain_passes() {
  bazel build --extra_toolchains="//manual_test/scalac_jvm_opts:passing_scala_toolchain" //manual_test/scalac_jvm_opts:empty_build
}

test_scalac_jvm_flags_work_with_scalapb() {
  bazel build --extra_toolchains="//manual_test/scalac_jvm_opts:passing_scala_toolchain" //manual_test/scalac_jvm_opts:proto
}

$runner test_scalac_jvm_flags_on_target_overrides_toolchain_passes
$runner test_scalac_jvm_flags_from_scala_toolchain_passes
$runner test_scalac_jvm_flags_work_with_scalapb
