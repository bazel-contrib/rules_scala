#!/usr/bin/env bash

# shellcheck source=./test_runner.sh
dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

revert_internal_change() {
  sed -i.bak "s/println(\"altered\")/println(\"orig\")/" $no_recompilation_path/C.scala
  rm $no_recompilation_path/C.scala.bak
}

revert_change() {
  mv $1/$2.bak $1/$2
}

test_scala_library_expect_no_recompilation_on_internal_change() {
  changed_file=$1
  changed_content=$2
  dependency=$3
  dependency_description=$4
  set +e
  no_recompilation_path="test/src/main/scala/scalarules/test/ijar"
  build_command="bazel build //$no_recompilation_path/... --subcommands"

  echo "running initial build"
  $build_command
  echo "changing internal behaviour of $changed_file"
  sed -i.bak $changed_content ./$no_recompilation_path/$changed_file

  echo "running second build"
  output=$(${build_command} 2>&1)

  not_expected_recompiled_action="$no_recompilation_path$dependency"

  echo ${output} | grep "$not_expected_recompiled_action"
  if [ $? -eq 0 ]; then
    echo "bazel build was executed after change of internal behaviour of 'dependency' target. compilation of $dependency_description should not have been triggered."
    revert_change $no_recompilation_path $changed_file
    exit 1
  fi

  revert_change $no_recompilation_path $changed_file
  set -e
}

test_scala_library_expect_no_recompilation_of_target_on_internal_change_of_dependency() {
  test_scala_library_expect_no_recompilation_on_internal_change $1 $2 ":user" "'user'"
}

test_scala_library_expect_no_recompilation_on_internal_change_of_transitive_dependency() {
  set +e
  no_recompilation_path="test/src/main/scala/scalarules/test/strict_deps/no_recompilation"
  build_command="bazel build //$no_recompilation_path/... --subcommands --extra_toolchains=//test/toolchains:high_level_transitive_deps_strict_deps_error"

  echo "running initial build"
  $build_command
  echo "changing internal behaviour of C.scala"
  sed -i.bak "s/println(\"orig\")/println(\"altered\")/" ./$no_recompilation_path/C.scala

  echo "running second build"
  output=$(${build_command} 2>&1)

  not_expected_recompiled_target="//$no_recompilation_path:transitive_dependency_user"

  echo ${output} | grep "$not_expected_recompiled_target"
  if [ $? -eq 0 ]; then
    echo "bazel build was executed after change of internal behaviour of 'transitive_dependency' target. compilation of 'transitive_dependency_user' should not have been triggered."
    revert_internal_change
    exit 1
  fi

  revert_internal_change
  set -e
}

test_scala_library_expect_no_recompilation_on_internal_change_of_scala_dependency() {
  test_scala_library_expect_no_recompilation_of_target_on_internal_change_of_dependency "B.scala" "s/println(\"orig\")/println(\"altered\")/"
}

test_scala_library_expect_no_recompilation_on_internal_change_of_java_dependency() {
  test_scala_library_expect_no_recompilation_of_target_on_internal_change_of_dependency "C.java" "s/System.out.println(\"orig\")/System.out.println(\"altered\")/"
}

test_scala_library_expect_no_java_recompilation_on_internal_change_of_scala_sibling() {
  test_scala_library_expect_no_recompilation_on_internal_change "B.scala" "s/println(\"orig_sibling\")/println(\"altered_sibling\")/" "/dependency_java" "java sibling"
}

$runner test_scala_library_expect_no_recompilation_on_internal_change_of_transitive_dependency
$runner test_scala_library_expect_no_recompilation_on_internal_change_of_scala_dependency
$runner test_scala_library_expect_no_recompilation_on_internal_change_of_java_dependency
$runner test_scala_library_expect_no_java_recompilation_on_internal_change_of_scala_sibling
