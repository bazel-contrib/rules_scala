#!/bin/sh

# This is used by a sh_test to test whether a string is
# found in a file.
#
# Args:
# . $1: Whether the string should be in the file (accepted values are "true" or "false")
# . $2: String to look for in the file.
# . $3: File to look the string into.
#
# This is used for instance to check if
# stray jars are not making it onto the classpath

should_be_in_file=$1

if test "$should_be_in_file" != "true" -a "$should_be_in_file" != "false" ; then
  echo "ERROR: Please use only (\"true\" or \"false\") to specify whether you need the substring to be in the file."
  echo "Refer to test/string_checks/string_in_file.sh for documentation."
  exit 1
fi

grep -q -F -- "$2" "$3"
string_is_in_file=$?

# grep exits 2 when it could not read the file, which lands in the same branch
# as "not found", so a "false" expectation would pass for free.
if [ $string_is_in_file -gt 1 ] ; then
  echo "ERROR: Could not search $3 for $2."
  exit 1
fi

if [ $string_is_in_file -eq 0 ] ; then
  if test "$should_be_in_file" = "true" ; then
    exit 0
  else
    echo "ERROR: Found string $2 in $3, when we were expecting not to find it."
    exit 1
  fi
else
  if test "$should_be_in_file" = "true" ; then
    echo "ERROR: Not found string $2 in $3, when we were expecting to find it."
    exit 1
  else
    exit 0
  fi
fi
