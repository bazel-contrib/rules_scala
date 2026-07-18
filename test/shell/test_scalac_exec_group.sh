#!/usr/bin/env bash

# shellcheck source=./test_runner.sh

dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. "${dir}"/test_runner.sh
. "${dir}"/test_helper.sh
runner=$(get_test_runner "${1:-local}")

# The regression targets in //test:ScalacExecGroup* set
# `exec_properties = {"scalac.cpu": "1"}`, which requires the rule to declare
# the "scalac" exec_group. Analysis alone catches removal of that rule-level
# declaration. This test additionally verifies via `bazel aquery` that the
# property actually reaches the Scalac action's ExecutionInfo, which catches
# removal of `exec_group = "scalac"` from `ctx.actions.run` in compile_scala
# (a change that would silently reroute the property to the default group).

SCALAC_EXEC_GROUP_TARGETS=(
  //test:ScalacExecGroupLib
  //test:ScalacExecGroupMacro
  //test:ScalacExecGroupLibForPluginBootstrapping
  //test:ScalacExecGroupBinary
  //test:ScalacExecGroupTest
  //test:ScalacExecGroupJunitTest
  //test:ScalacExecGroupRepl
)

test_scalac_action_receives_exec_property() {
  local target output
  for target in "${SCALAC_EXEC_GROUP_TARGETS[@]}"; do
    output="$(bazel aquery "mnemonic(\"Scalac\", ${target})" 2>&1)"
    assert_matches 'ExecutionInfo:.*cpu: 1' "$output" \
      "Scalac action on ${target} did not receive scalac.cpu=1 via exec_properties"
  done
}

# scala_proto_library and scrooge_scala_library run Scalac via an aspect,
# and Bazel doesn't propagate target-level exec_properties to aspect actions.
# The top-level rules intentionally omit the scalac exec_group so users get
# an analysis error instead of a silently-dropped config — verify that.
ASPECT_RULE_TARGETS=(
  //test_expect_failure/scalac_exec_group_on_aspect_rule:scala_proto_library_with_scalac_exec_property
  //test_expect_failure/scalac_exec_group_on_aspect_rule:scrooge_scala_library_with_scalac_exec_property
)

test_scalac_exec_property_fails_on_aspect_rules() {
  local target
  for target in "${ASPECT_RULE_TARGETS[@]}"; do
    action_should_fail_with_message \
      'Tried to set properties for non-existent exec groups: scalac' \
      build "${target}"
  done
}

$runner test_scalac_action_receives_exec_property
$runner test_scalac_exec_property_fails_on_aspect_rules
