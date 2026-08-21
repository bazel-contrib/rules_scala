#!/usr/bin/env bash
#
# Run this from the repo root after `exposed_source_packages_test` fails.
# It appends a `package_sources` filegroup to any BUILD/BUILD.bazel file under
# scala/, src/, third_party/ that's missing one, and rewrites
# EXPOSED_SOURCE_PACKAGES in exposed_source_packages.bzl to match what's
# really on disk (pruning entries for packages that no longer exist).
#
# Same child-workspace pruning as exposed_source_packages_test.sh: a
# WORKSPACE/WORKSPACE.bazel file marks a package Bazel already walls off from
# this module, so it's skipped here too.
#
# Usage: test/community_build/update_exposed_source_packages.sh

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "${root}"

child_workspace_dirs="$(find scala src third_party \( -name WORKSPACE -o -name WORKSPACE.bazel \) -exec dirname {} \;)"

packages="$(
  find scala src third_party \( -name BUILD -o -name BUILD.bazel \) -exec dirname {} \; | while IFS= read -r pkg; do
    skip=0
    while IFS= read -r child; do
      [[ -z "${child}" ]] && continue
      if [[ "${pkg}" == "${child}" || "${pkg}" == "${child}"/* ]]; then
        skip=1
        break
      fi
    done <<< "${child_workspace_dirs}"
    [[ "${skip}" -eq 0 ]] && printf '%s\n' "${pkg}"
  done | sort
)"

while IFS= read -r pkg; do
  build="${pkg}/BUILD"
  [[ -f "${build}" ]] || build="${pkg}/BUILD.bazel"
  if ! grep -q 'name = "package_sources"' "${build}"; then
    cat >> "${build}" <<'EOF'

filegroup(
    name = "package_sources",
    srcs = glob(["**/*"], allow_empty = True),
    visibility = ["//test/community_build:__pkg__"],
)
EOF
    echo "Added package_sources filegroup to ${build}"
  fi
done <<< "${packages}"

python3 - "${packages}" <<'PYEOF'
import re
import sys

packages = sys.argv[1].splitlines()
path = "test/community_build/exposed_source_packages.bzl"
with open(path) as f:
    content = f.read()

entries = "".join('    "%s",\n' % p for p in packages)
new_list = "EXPOSED_SOURCE_PACKAGES = [\n%s]" % entries
content = re.sub(
    r"EXPOSED_SOURCE_PACKAGES = \[.*?\]",
    new_list,
    content,
    count=1,
    flags=re.S,
)
with open(path, "w") as f:
    f.write(content)
PYEOF

echo "Rewrote EXPOSED_SOURCE_PACKAGES in test/community_build/exposed_source_packages.bzl"
echo "Review the diff, then re-run: bazel test //test/community_build:exposed_source_packages_test"
