#!/usr/bin/env bash

set -e

repo_root=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

find "$repo_root" -name "MODULE.bazel" -type f -print -execdir bazel mod deps --lockfile_mode=update \;

echo "All lockfiles updated!"
