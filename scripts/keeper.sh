#!/bin/bash

ganache-cli -b ${BLOCK_TIME} --hostname "${LISTEN_ADDRESS}" --port "${LISTEN_PORT}" &

sleep 2

truffle migrate

tail -f /dev/null
