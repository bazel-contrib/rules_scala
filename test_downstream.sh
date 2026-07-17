#!/usr/bin/env bash
#
# Builds and tests real external projects (currently joern, databricks/dicer)
# against this rules_scala checkout, to catch consumer-breaking changes
# before they ship. See #1866.
#
# Every test is skipped by default -- this is a no-op unless you select one:
#
#   RULES_SCALA_TEST_ONLY=_test_downstream_joern ./test_downstream.sh
#
# `.bazelci/presubmit.yml` runs this on every PR too, but with nothing
# selected it costs nothing. To run it for real against a given PR/commit,
# rebuild that step in Buildkite ("New Build") with a custom environment
# variable: RULES_SCALA_TEST_REGEX=_test_downstream
#
# See test/shell/test_downstream.sh for the actual test definitions,
# including how to add a new consumer.

set -e

test_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/test/shell

. "${test_dir}"/test_downstream.sh
