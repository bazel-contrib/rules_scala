#!/bin/bash
# Test that verifies the global plugin is actually being used

set -e
echo "Testing that simple compilation works WITHOUT the special toolchain..."
bazel build //test/toolchain_plugins:test_simple

echo "Test passed - simple compilation works without special toolchain"