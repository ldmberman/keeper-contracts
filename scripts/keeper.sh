#!/bin/bash

[ "${LOCAL_CONTRACTS}" = "true" ] && rm -f /keeper-contracts/artifacts/ready
ganache-cli -d -b ${BLOCK_TIME} --hostname "${LISTEN_ADDRESS}" --port "${LISTEN_PORT}" &

sleep 2

truffle migrate

# Flag to indicate contracts are ready
[ "${LOCAL_CONTRACTS}" = "true" ] && touch /keeper-contracts/artifacts/ready

tail -f /dev/null

