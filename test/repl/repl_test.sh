#!/usr/bin/env bash
#
# Feeds a snippet of Scala to each scala_repl binary's stdin and checks its
# output, exercising the repl wrapper end to end (classpath, jline flag,
# stdin handling).
#
# Usage:
#   repl_test.sh --hello-lib-repl <path> --hello-lib-test-repl <path> \
#       --scala-lib-binary-repl <path> --resources-strip-scala-binary-repl <path> \
#       --repl-with-sources <path>

set -euo pipefail

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --hello-lib-repl) hello_lib_repl="$2"; shift 2 ;;
    --hello-lib-test-repl) hello_lib_test_repl="$2"; shift 2 ;;
    --scala-lib-binary-repl) scala_lib_binary_repl="$2"; shift 2 ;;
    --resources-strip-scala-binary-repl) resources_strip_scala_binary_repl="$2"; shift 2 ;;
    --repl-with-sources) repl_with_sources="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done

echo "import scalarules.test._; HelloLib.printMessage(\"foo\")" | "${hello_lib_repl}" -Xnojline | grep "foo java"
echo "import scalarules.test._; TestUtil.foo" | "${hello_lib_test_repl}" -Xnojline | grep "bar"
echo "import scalarules.test._; ScalaLibBinary.main(Array())" | "${scala_lib_binary_repl}" -Xnojline | grep "A hui hou"
echo "import scalarules.test._; ResourcesStripScalaBinary.main(Array())" | "${resources_strip_scala_binary_repl}" -Xnojline | grep "More Hello"
echo "import scalarules.test._; A.main(Array())" | "${repl_with_sources}" -Xnojline | grep "4 8 15"
