#!/bin/bash


REPORT_FILE=cppcheck_report.txt

# SRCS="../Core/Src/main.c"
SRCS="../Core/Src/main.c ../User ../SICE"

INCLUDE_PATHS=";$(cat ../.mxproject | grep HeaderPath= | sed -E 's/HeaderPath=(.*);/\1/')"
INCLUDES="$(echo ${INCLUDE_PATHS} | sed 's/;/ -I ..\//g')"
echo $INCLUDES
echo '---------------------------------------------------------------------'

# TEMPLATE=--template='{file}:{line},{severity},{id},{message}'
TEMPLATE=--template=gcc

ENABLES="--enable=all"
# DISABLES=--disable=style

ADDON="--addon=misra --addon=threadsafety --addon=naming --addon=misc"

SUPPRESS_TOPICS=";missingIncludeSystem;missingInclude;unusedFunction;cstyleCast;duplicateBreak;constVariablePointer"
SUPPRESS_TOPICS=";missingIncludeSystem;missingInclude;unusedFunction;cstyleCast;duplicateBreak"
SUPPRESSES="$(echo ${SUPPRESS_TOPICS} | sed 's/;/ --suppress=/g')"
echo $SUPPRESSES
echo '---------------------------------------------------------------------'

           # The available ids are:

           # all
           #     Enable all checks. It is recommended to only use --enable=all when the
           #     whole program is scanned, because this enables unusedFunction.

           # warning
           #     Enable warning messages

           # style
           #     Enable all coding style checks. All messages with the severities
           #     'style', 'performance' and 'portability' are enabled.

           # performance
           #     Enable performance messages

           # portability
           #     Enable portability messages

           # information
           #     Enable information messages

           # unusedFunction
           #     Check for unused functions. It is recommend to only enable this when
           #     the whole program is scanned

           # missingInclude
           #     Warn if there are missing includes

cppcheck \
  -j $(nproc)     \
  --checkers-report=${REPORT_FILE} \
  --inconclusive  \
  ${ENABLES} ${DISABLES} \
  ${ADDON}        \
  ${TEMPLATE}     \
  ${SUPPRESSES}   \
  ${INCLUDES}     \
  ${SRCS} --force --quiet

echo --------
cat ${REPORT_FILE}
