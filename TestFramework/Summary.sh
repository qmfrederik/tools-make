#!/bin/sh
#
# Script to generate summary/advice based on the datain tests.sum
#
# Authors of individual testsuites may supply their own implementation
# of Summary.sh to be used if someone runs their test framework.
#
# The script may examine the contents of tests.sum (containing totals of
# each kind of test result) or tests.log (the full testrun log) to decide
# what sort of summary to present.
#
# The script may also use the value of the GSTESTMODE variable to decide
# what it does.
#

if [ "$GSTESTMODE" = "clean" ]
then
  exit 0
fi

# Function for platforms where grep can't search for multiple patterns.
present()
{
  f=$1
  shift
  while test $# != 0
  do
    grep "$1" "$f" >/dev/null
    if [ $? = "0" ]
    then
      return 0
    fi
    shift
  done
  return 1
}

present "tests.sum" "Failed set$" "Failed sets$" "Failed test$" "Failed tests$" "Failed build$" "Failed builds$" "Failed file$" "Failed files$" "Failed script$" "Failed scripts$"
if [ $? = 1 ]
then
  echo "All OK!"

  if present "tests.sum" "Dashed hope$" "Dashed hopes$"
  then
    echo 
    echo "But we were hoping that even more tests might have passed if"
    echo "someone had added support for them to the package.  If you"
    echo "would like to help, please contact the package maintainer."
  fi

  if present "tests.sum" "Skipped set$" "Skipped sets$"
  then
    echo 
    echo "Even though no tests failed, we had to skip some testing"
    echo "due to lack of support on your system.  This might be because"
    echo "some required software library was just not available when the"
    echo "software was built (in which case you can install that library"
    echo "and rebuild, then re-run the tests), or the required functions"
    echo "may not be available on your operating system at all."
    echo "If you would like to contribute code to add the missing"
    echo "functionality, please contact the package maintainer."
  fi

else
  if [ "$GSTESTMODE" = "failfast" ]
  then
    exit 0
  fi

  if present "tests.sum" "Failed script$" "Failed script$"
  then
    echo
    echo "Unfortunately the script to build and run the tests did not work."
    echo "This means that there is a problem with the test framework itsself"
    echo "probably due to some system specific problems with the shell"
    echo "or a problem wiith the installation of the test framework."
  fi

  if present "tests.sum" "Failed build$" "Failed build$"
  then
    echo
    echo "Unfortunately we could not even compile all the test programs."
    echo "This means that the test could not be run properly, and you need"
    echo "to try to figure out why and fix it or ask for help."
  fi

  if present "tests.sum" "Failed file$" "Failed files$"
  then
    echo
    echo "Some testing was abandoned when a test program aborted.  This is"
    echo "generally a severe problem and may nean that the package is"
    echo "completely unusuable.  You need to try to fix this and, if it's"
    echo "not due to some problem on your system, please help by submitting"
    echo "a patch (or at least a bug report) to the package maintainer."
  fi

  if present "tests.sum" "Failed set$" "Failed sets$"
  then
    echo
    echo "Some set of tests failed.  This could well mean that a large"
    echo "number of individual tests dis not pass and that there are"
    echo "severe problems in the software."
    echo "Please submit a patch to fix the problem or send a bug report to"
    echo "the package maintainer."
  fi

  if present "tests.sum" "Failed test$" "Failed tests$"
  then
    echo
    echo "One or more tests failed.  None of them should have."
    echo "Please submit a patch to fix the problem or send a bug report to"
    echo "the package maintainer."
  fi
fi
