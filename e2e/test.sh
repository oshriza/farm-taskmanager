#!/bin/bash
set -e

URL=$1
WAIT="sleep 0.7"
TEST_CODE=$?
Green='\033[0;32m'
RED="\e[31m"
ENDCOLOR="\e[0m"

check_rest_api() {
    echo "CHECKING POST REQUEST..."
    if [ "$(curl -d '{"title": "title-test", "description": "description test"}' -is http://"$URL"/api/todo/ | head -n 1 | awk '" " {print $2}')" = '200' ]; then 
        echo -e "${Green}POST request test is completed successfully${ENDCOLOR}" 
    else 
        echo -e "${RED}POST request failed${ENDCOLOR}"
        exit 1
    fi
    echo "CHECKING GET REQUEST..."
    $WAIT
    if [ "$(curl -is http://"$URL"/api/todo | head -n 1 | awk '" " {print $2}')" = '200' ]; then 
        echo -e "${Green}GET request test is completed successfully${ENDCOLOR}" 
    else 
        echo -e "${RED}GET request failed${ENDCOLOR}"
        exit 1
    fi

    echo "CHECKING PUT REQUEST..."
    $WAIT
    if [ "$(curl -X 'PUT' -is http://"$URL"/api/todo/title-test/?desc=test-update | head -n 1 | awk '" " {print $2}')" = '200' ]; then 
        echo -e "${Green}PUT request test is completed successfully${ENDCOLOR}" 
    else 
        echo -e "${RED}PUT request failed${ENDCOLOR}"
        exit 1
    fi

    echo "CHECKING DELETE REQUEST..."
    $WAIT
    if [ "$(curl -X 'DELETE' -is http://"$URL"/api/todo/title-test | head -n 1 | awk '" " {print $2}')" = '200' ]; then 
        echo -e "${Green}DELETE request test is completed successfully${ENDCOLOR}" 
    else 
        echo -e "${RED}DELETE request failed${ENDCOLOR}"
        exit 1
    fi
}


wait_for_healthy() {
    echo "Testing $1"
    timeout --foreground -s TERM 30s bash -c \
        'while [[ "$(curl -s -o /dev/null -m 3 -L -w ''%{http_code}'' ${0})" != "200" ]];\
        do echo "Waiting for ${0}" && sleep 5;\
        done' ${1}
    echo -e "${Green}${1} - OK!${ENDCOLOR}"
}

echo "Wait for URLs: $@"

for var in "$@"; do
    wait_for_healthy "$var"
done

if [ $TEST_CODE -eq 0 ]; then
    echo "Service is alive, checking api..."

    check_rest_api

    exit 0
else 
    echo "Test failed with exit code: $?"
    exit $?
fi


# curl -X 'GET' http://$URL/api/todo --silent -H 'accept: application/json'