# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

set -euox pipefail

# TODO: These refs are different.
classes_file=$(rlocation rules_scala/test/scala_export/classes.txt)

if grep -q DeployEnvDependency.class "$classes_file"; then
  echo "Unexpectedly found DeployEnvDependency class in jar"
  exit 1
fi

if ! grep -q Dependency.class "$classes_file"; then
  echo "Missing Dependency class from jar"
  exit 1
fi

if ! grep -q Main.class "$classes_file"; then
  echo "Missing Main class from jar"
  exit 1
fi  
