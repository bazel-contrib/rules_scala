#!/usr/bin/env bash
#
# Script to build custom version of `JacocoCoverage_jarjar_deploy.jar` from Jacoco and Bazel repositories.
#
# The script has three flavours: Bazel 5, 6 and 7. Documenting the details for Bazel 7 here.
#
# The default `JacocoCoverage_jarjar_deploy.jar` has some issues:
#
# 1. Scala support on newer Jacoco versions (including 0.8.11) is still lacking some functionality
#
#    E.g. a lot of generated methods for case classes, lazy vals or other Scala features are causing falsely missed branches in branch coverage.
#
#    Proposed changes in:
#    https://github.com/gergelyfabian/jacoco/tree/scala
#
#    Backported to 0.8.11 (to be usable with current Bazel):
#    https://github.com/gergelyfabian/jacoco/tree/0.8.11-scala
#
# 2. Bazel's code for generating `JacocoCoverage_jarjar_deploy.jar` needs changes after our Jacoco changes
#
#    It implements an interface that we have extended, so that implementation also needs to be extended.
#
#    This has been added on https://github.com/gergelyfabian/bazel/tree/7.0.2_jacoco_0.8.11_scala.
#
# You can use this script to build a custom version of `JacocoCoverage_jarjar_deploy.jar`, including any fixes from the above list you wish
# and then provide the built jar as a parameter of `java_toolchain` and/or `scala_toolchain` to use the changed behavior for coverage.
#
# Choose the fixes from the above list by configuring the used branch for Jacoco/Bazel repos below.
#
# Patches:
#
# There are also some patches that may need to be applied for Jacoco, according to your preferences:
#
# 1. Bazel is compatible only with Jacoco in a specific package name. This is not Jacoco-specific, so not committed to the Jacoco fork.
#    See 0001-Build-Jacoco-for-Bazel-*.patch (for each Bazel version).
# 2. Building Jacoco behind a proxy needs a workaround.
#    See 0002-Build-Jacoco-behind-proxy.patch.
#
# Set up the patch file names in `jacoco_patches`.
#
# Dependencies:
#
# On OS X greadlink is needed (by running `brew install coreutils`).

set -e

# Note!!
# Ensure Java 8 is used for building Jacoco <0.8.11 (experienced issue when using e.g. Java 17).
# Java 17+ is needed for Jacoco 0.8.11+.
#
# If it's necessary and this matches your system, you could uncomment these lines:
#export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
#export PATH=$JAVA_HOME/bin:$PATH

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  readlink_cmd="readlink"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  readlink_cmd="greadlink"
else
  echo "OS not supported: $OSTYPE"
  exit 1
fi

source_path=$($readlink_cmd -f $(dirname ${BASH_SOURCE[0]}))

build_dir=/tmp/bazel_jacocorunner_build

mkdir -p $build_dir

# Read the Bazel major version.
bazel_major_version=$1
if [ -z "$bazel_major_version" ]; then
  echo "Please provide Bazel major version"
  exit 1
elif [ "$bazel_major_version" != "5" ] && [ "$bazel_major_version" != "6" ] && [ "$bazel_major_version" != "7" ]; then
  echo "Unsupported Bazel major version: $bazel_major_version"
  exit 1
fi
echo "Selected Bazel major version: $bazel_major_version"

jacoco_repo=$build_dir/jacoco
# Take a fork for Jacoco that contains Scala fixes.
jacoco_remote=https://github.com/gergelyfabian/jacoco

# Choose the patches that you'd like to use:
jacoco_patches=""
# Bazel needs to have a certain Jacoco package version (dependent on Bazel major version):
jacoco_patches="$jacoco_patches 0001-Build-Jacoco-for-Bazel-$bazel_major_version.0.patch"
# Uncomment this if you are behind a proxy:
#jacoco_patches="$jacoco_patches 0002-Build-Jacoco-behind-proxy.patch"

bazel_repo=$build_dir/bazel
bazel_remote=https://github.com/gergelyfabian/bazel
if [ "$bazel_major_version" = "5" ]; then
  # Take further fixes for Scala (2.11, 2.12 and 2.13) - branch in development:
  jacoco_branch=0.8.7-scala
  jacoco_version=0.8.7
  bazel_version=6.0.0-pre.20220520.1
  # Version of Bazel with extending Bazel's Jacoco interface implementation for our 0.8.7-scala jacoco branch.
  bazel_branch=jacoco_0.8.7_scala
elif [ "$bazel_major_version" = "6" ]; then
  # Take further fixes for Scala (2.11, 2.12 and 2.13) - branch in development:
  jacoco_branch=0.8.7-scala
  jacoco_version=0.8.7
  bazel_version=6.3.2
  # Version of Bazel with extending Bazel's Jacoco interface implementation for our 0.8.7-scala jacoco branch.
  bazel_branch=6.3.2_jacoco_0.8.7_scala
else
  # Take further fixes for Scala (2.11, 2.12 and 2.13) - branch in development:
  jacoco_branch=0.8.11-scala
  jacoco_version=0.8.11
  bazel_version=7.0.2
  # Version of Bazel with extending Bazel's Jacoco interface implementation for our 0.8.11-scala jacoco branch.
  bazel_branch=7.0.2_jacoco_0.8.11_scala
fi

JAVA_VERSION=$(java -version 2>&1 | head -1 \
                                  | cut -d'"' -f2 \
                                  | sed 's/^1\.//' \
                                  | cut -d'.' -f1)

if [ "$bazel_major_version" == "7" ]; then
  if [ "$JAVA_VERSION" != "17" ]; then
    echo "Unexpected java version: $JAVA_VERSION"
    echo "Please ensure this script is run with Java 17"
    exit 1
  fi
else
  if [ "$JAVA_VERSION" != "8" ]; then
    echo "Unexpected java version: $JAVA_VERSION"
    echo "Please ensure this script is run with Java 8"
    exit 1
  fi
fi

bazel_build_target=JacocoCoverage_jarjar_deploy.jar

destination_dir=$build_dir

# Generate the jar.

if [ ! -d $jacoco_repo ]; then
  (
  cd $(dirname $jacoco_repo)
  git clone $jacoco_remote
  )
fi

if [ ! -d $bazel_repo ]; then
  (
  cd $(dirname $bazel_repo)
  git clone $bazel_remote
  )
fi

(
cd $jacoco_repo
git remote update
git checkout origin/$jacoco_branch
# Need to patch Jacoco:
for patch in $jacoco_patches; do
  git am $source_path/$patch
done
mvn clean install
)

(
cd $bazel_repo
git remote update
git reset --hard HEAD
git checkout $bazel_branch

echo "$bazel_version" > .bazelversion

# Prepare Jacoco version.
cd third_party/java/jacoco
# Remove any previously unpacked Jacoco files.
rm -rf coverage/ doc/ index.html lib/ test/
unzip $HOME/.m2/repository/org/jacoco/jacoco/${jacoco_version}/jacoco-${jacoco_version}.zip
cp lib/jacocoagent.jar jacocoagent-${jacoco_version}.jar
cp lib/org.jacoco.agent-* org.jacoco.agent-${jacoco_version}.jar
cp lib/org.jacoco.core-* org.jacoco.core-${jacoco_version}.jar
cp lib/org.jacoco.report-* org.jacoco.report-${jacoco_version}.jar
cd ../../..

# Build JacocoRunner.
bazel build src/java_tools/junitrunner/java/com/google/testing/coverage:$bazel_build_target
cp bazel-bin/src/java_tools/junitrunner/java/com/google/testing/coverage/$bazel_build_target $destination_dir/
# Make the jar writable to enable re-running the script.
chmod +w $destination_dir/$bazel_build_target

echo "JacocoRunner is available at: $destination_dir/$bazel_build_target"
)
