#!/bin/sh
set -e
URL=$1

# TEST=$(curl -s -o /dev/null -I -w "%{http_code}\n" "$URL")
curl -s -o /dev/null -I -w "%{http_code}\n" "$URL"
TEST_CODE=$?
# echo "$TEST"

if [ $TEST_CODE -eq 0 ]; then
    echo "Success, exit code: $?"
    exit 0
else 
    echo "Test failed with exit code: $?"
    exit $?
fi