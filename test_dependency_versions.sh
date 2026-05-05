#!/usr/bin/env bash
#
# Verifies combinations of supported dependency versions.
#
# Starts by testing the oldest dependency versions, then increments some of them
# to more recent versions. These versions should match the guidance in these
# `README.md` sections:
#
# - Compatible Bazel versions
# - Using a prebuilt protocol compiler > Minimum dependency versions
#
# Does not test the latest dependency versions, as all other tests in the suite
# already do this. Only builds with Bzlmod, as `WORKSPACE` builds are now
# considered legacy.

set -e

dir="$( cd "${BASH_SOURCE[0]%/*}" && echo "${PWD}" )"
test_source="${dir}/${BASH_SOURCE[0]##*/}"
# shellcheck source=./test_runner.sh
. "${dir}"/test/shell/test_runner.sh
. "${dir}"/test/shell/test_helper.sh

prebuilt_protoc_regex=''

setup_suite() {
  original_dir="$PWD"
  setup_test_tmpdir_for_file "$dir" "$test_source"
  test_tmpdir="$PWD"

  # Windows now requires a prebuilt protoc. The non-prebuilt tests on macOS run
  # so slowly in continuous integration that we skip them in that environment.
  if ( is_windows || ( is_macos && [[ -n "${CI:-}" ]] )) &&
     [[ -z "$RULES_SCALA_TEST_REGEX" ]]; then
    prebuilt_protoc_regex="test_prebuilt_protoc"
  fi
}

teardown_suite() {
  teardown_test_tmpdir "$original_dir" "$test_tmpdir"
}

# Explicitly disable this, since this test sets the Bazel version.
export USE_BAZEL_VERSION=""

RULES_SCALA_TARGETS=(
  "//test:HelloLibTest"
  "//test:ScalaBinary"
  "//test:ScalaDocTestLibsOnly"
  "//test/jmh:jmh_command_line_parsing_test"
  "//test/proto:standalone_scala_proto_outs_test"
  "//test/src/main/scala/scalarules/test/twitter_scrooge:twitter_scrooge_tests"
)

MULTI_FRAMEWORKS_TOOLCHAIN_TARGETS=(
  "//example:scalatest_example"
  "//example:specs2_example"
)

ALL_TARGETS=(
  "//..."
  "${RULES_SCALA_TARGETS[@]/#/@rules_scala}"
  "${MULTI_FRAMEWORKS_TOOLCHAIN_TARGETS[@]/#/@multi_frameworks_toolchain}"
)

parse_major_and_minor_versions() {
  local flag_name="$1"
  local full_version="$2"
  local major_varname="$3"
  local minor_varname="$4"

  if [[ "$full_version" =~ ^([0-9]+)\.([0-9]+)(\.[0-9]+.*)? ]]; then
    printf -v "$major_varname" "${BASH_REMATCH[1]}"
    printf -v "$minor_varname" "${BASH_REMATCH[2]}"
  else
    echo "can't parse --$flag_name: $full_version" >&2
    exit 1
  fi
}

do_build_and_test() {
  # These are the minimum supported dependency versions as described in
  # `README.md` and as set in the top level `MODULE.bazel` file. Update both
  # if/when a test fails and the appropriate solution is to increase any of
  # these minimum suported versions.
  local bazelversion="7.1.0"
  local skylib_version="1.8.0"
  local platforms_version="0.0.9"
  local protobuf_version="28.2"
  local rules_java_version="7.6.0"
  local rules_proto_version="6.0.0"
  local protoc_toolchain=""
  local legacy_api=""
  local bazel_major=""
  local bazel_minor=""
  local protobuf_major=""
  local protobuf_minor=""
  local current
  local arg

  while [[ "$#" -ne  0 ]]; do
    current="$1"
    shift
    arg="${current#*=}"

    case "$current" in
    --bazelversion=*)
      bazelversion="$arg"
      ;;
    --skylib=*)
      skylib_version="$arg"
      ;;
    --platforms=*)
      platforms_version="$arg"
      ;;
    --protobuf=*)
      protobuf_version="$arg"
      ;;
    --rules_java=*)
      rules_java_version="$arg"
      ;;
    --rules_proto=*)
      rules_proto_version="$arg"
      ;;
    --protoc_toolchain=*)
      protoc_toolchain="$arg"
      case "$protoc_toolchain" in
      rules_scala|protobuf)
        ;;
      *)
        echo "unknown --protoc_toolchain value: ${arg}" >&2
        exit 1
        ;;
      esac
      ;;
    --legacy_api)
      legacy_api="true"
      ;;
    *)
      echo "unknown flag: ${current}" >&2
      exit 1
      ;;
    esac
  done

  parse_major_and_minor_versions \
    'bazelversion' "$bazelversion" 'bazel_major' 'bazel_minor'
  parse_major_and_minor_versions \
    'protobuf' "$protobuf_version" 'protobuf_major' 'protobuf_minor'

  set -e
  echo "$bazelversion" >.bazelversion

  # Set up .bazelrc
  printf '%s\n' \
    'common --noenable_workspace --enable_bzlmod' \
    'common --enable_platform_specific_config' \
    'common:windows --worker_quit_after_build --enable_runfiles' >.bazelrc

  if [[ -n "$protoc_toolchain" ]]; then
    echo 'common --incompatible_enable_proto_toolchain_resolution' >>.bazelrc

    if [[ "$protoc_toolchain" == "protobuf" ]]; then
      echo 'common --@protobuf//bazel/toolchains:prefer_prebuilt_protoc' \
        >>.bazelrc
    fi

  elif [[ "$bazel_major" == "9" ]]; then
    echo 'common --noincompatible_enable_proto_toolchain_resolution' >>.bazelrc

  elif [[ "$bazel_major" == "7" ]]; then
    printf '%s\n' \
      'common:linux --cxxopt=-std=c++17' \
      'common:linux --host_cxxopt=-std=c++17' \
      'common:macos --cxxopt=-std=c++17' \
      'common:macos --host_cxxopt=-std=c++17' \
      'common:windows --cxxopt=/std=c++17' \
      'common:windows --host_cxxopt=/std=c++17' >>.bazelrc
  fi

  if [[ "$legacy_api" == "true" ]]; then
    echo 'common --experimental_google_legacy_api' >>.bazelrc
  fi

  if [[ "$bazel_major" == "7" && "$bazel_minor" -ge 3 ]]; then
    echo 'common --incompatible_use_plus_in_repo_names' >>.bazelrc
  fi

  # Set up the `protobuf` prebuilt protocol compiler toolchain patch.
  if [[ ( "$protobuf_major" -ge 29 && "$protobuf_major" -lt 33 ) ||
        ( "$protobuf_major" -eq 33 && "$protobuf_minor" -lt 4  ) ]]; then
    cp "${dir}/protoc/0001-protobuf-19679-rm-protoc-dep.patch" ./protobuf.patch
  else
    echo '' >./protobuf.patch
  fi

  # Render the MODULE.bazel file and create an empty top level package.
  sed -e "s%\${skylib_version}%${skylib_version}%" \
    -e "s%\${platforms_version}%${platforms_version}%" \
    -e "s%\${protobuf_version}%${protobuf_version}%" \
    -e "s%\${rules_java_version}%${rules_java_version}%" \
    -e "s%\${rules_proto_version}%${rules_proto_version}%" \
    "${dir}/deps/test/MODULE.bazel.template" >MODULE.bazel

  if [[ "$protoc_toolchain" == "rules_scala" ]]; then
    cat "${dir}/deps/test/protoc_toolchains.template" >>MODULE.bazel
  fi

  # Copy files needed by the test targets
  cp "${dir}/deps/test/BUILD.bazel.test" BUILD
  cp "${dir}"/deps/test/defs.bzl \
    "${dir}/examples/testing/multi_frameworks_toolchain/example/ScalaTestExampleTest.scala" \
    .

  bazel build "${ALL_TARGETS[@]}"
  bazel test "${ALL_TARGETS[@]}"
}

test_minimum_supported_versions() {
  do_build_and_test
}

test_bazel_7_with_rules_java_8() {
  do_build_and_test --rules_java=8.4.0
}

test_prebuilt_protoc_rules_java_7() {
  do_build_and_test \
    --protoc_toolchain=rules_scala \
    --protobuf=29.0 \
    --rules_java=7.10.0 \
    --rules_proto=7.0.0 \
    --legacy_api
}

test_prebuilt_protoc_rules_java_8_3_2() {
  do_build_and_test \
    --protoc_toolchain=rules_scala \
    --protobuf=29.0 \
    --rules_java=8.3.2 \
    --rules_proto=7.0.0
}

test_prebuilt_protoc_from_protobuf_bazel_7() {
  do_build_and_test \
    --protoc_toolchain=protobuf \
    --protobuf=33.4 \
    --rules_java=7.10.0 \
    --rules_proto=7.1.0 \
    --legacy_api
}

test_prebuilt_protoc_rules_java_8_3_0() {
  do_build_and_test \
    --protoc_toolchain=rules_scala \
    --bazelversion=7.3.2 \
    --protobuf=29.0 \
    --rules_java=8.3.0 \
    --rules_proto=7.0.0
}

test_bazel_8() {
  do_build_and_test \
    --bazelversion=8.0.0 \
    --protobuf=29.0 \
    --rules_java=8.5.0 \
    --rules_proto=7.0.0
}

test_prebuilt_protoc_from_protobuf_bazel_8() {
  do_build_and_test \
    --protoc_toolchain=protobuf \
    --bazelversion=8.0.0 \
    --protobuf=33.4 \
    --rules_java=8.5.0 \
    --rules_proto=7.0.0
}

test_bazel_9() {
  do_build_and_test \
    --bazelversion=9.0.0 \
    --protobuf=33.0 \
    --rules_java=8.14.0 \
    --rules_proto=7.0.0
}

test_prebuilt_protoc_from_protobuf_bazel_9() {
  do_build_and_test \
    --protoc_toolchain=protobuf \
    --bazelversion=9.0.0 \
    --protobuf=33.4 \
    --rules_java=8.14.0 \
    --rules_proto=7.0.0
}

setup_suite
RULES_SCALA_TEST_REGEX="${RULES_SCALA_TEST_REGEX:-$prebuilt_protoc_regex}" \
  run_tests "$test_source" "$(get_test_runner "${1:-local}")"
teardown_suite
