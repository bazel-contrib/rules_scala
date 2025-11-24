#!/bin/bash

# Integration test for global compiler plugins via toolchain
set -e

echo "Testing global compiler plugins via toolchain..."

# Test 1: Build with global plugin from toolchain
echo "Test 1: Building with global plugin from toolchain"
bazel build --extra_toolchains=//test/toolchain_plugins:global_plugin_toolchain //test/toolchain_plugins:test_global_plugin

# Test 2: Build with combined plugins (global + target-specific)
echo "Test 2: Building with combined plugins"
bazel build --extra_toolchains=//test/toolchain_plugins:global_plugin_toolchain //test/toolchain_plugins:test_combined_plugins

# Test 3: Verify plugin is actually being used (should fail without the toolchain)
echo "Test 3: Verifying plugin requirement (should fail without toolchain)"
set +e
bazel build //test/toolchain_plugins:test_global_plugin 2>/dev/null
if [ $? -eq 0 ]; then
    echo "ERROR: Build succeeded without global plugin - test failed"
    exit 1
fi
set -e
echo "Good: Build correctly failed without the global plugin"

echo "All tests passed!"