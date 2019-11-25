#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

set -e

git submodule update --init
docker-compose stop
docker-compose up -d

cargo test --no-run

run_with_valgrind() {
    if ! valgrind --error-exitcode=100 --suppressions=rdkafka.suppressions --leak-check=full "$1" --nocapture
    then
        echo -e "${RED}*** Failure in $1 ***${NC}"
        exit 1
    fi
}

# UNIT TESTS

echo -e "${GREEN}*** Run unit tests ***${NC}"
for test_file in target/debug/rdkafka-*
do
    if [[ -x "$test_file" ]]
    then
        echo -e "${GREEN}Executing "$test_file"${NC}"
        run_with_valgrind "$test_file"
    fi
done
echo -e "${GREEN}*** Unit tests succeeded ***${NC}"

# INTEGRATION TESTS

echo -e "${GREEN}*** Run unit tests ***${NC}"
for test_file in target/debug/test_*
do
    if [[ -x "$test_file" ]]
    then
        echo -e "${GREEN}Executing "$test_file"${NC}"
        run_with_valgrind "$test_file"
    fi
done
echo -e "${GREEN}*** Integration tests succeeded ***${NC}"
