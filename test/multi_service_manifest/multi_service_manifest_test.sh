#!/usr/bin/env bash
#
# Checks that a scala_binary's deploy jar merges the META-INF/services file
# contributed by each of its dependencies into one manifest, rather than one
# dependency's entry silently overwriting the other's.
#
# Usage:
#   multi_service_manifest_test.sh <deploy-jar> <expected-manifest>

set -euo pipefail

deploy_jar="${1:?Usage: multi_service_manifest_test.sh <deploy-jar> <expected-manifest>}"
expected_manifest="${2:?Usage: multi_service_manifest_test.sh <deploy-jar> <expected-manifest>}"
meta_file='META-INF/services/org.apache.beam.sdk.io.FileSystemRegistrar'

actual_manifest="$(mktemp)"
trap 'rm -f "${actual_manifest}"' EXIT
unzip -p "${deploy_jar}" "${meta_file}" > "${actual_manifest}"

diff --strip-trailing-cr "${actual_manifest}" "${expected_manifest}"
