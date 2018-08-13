#!/bin/bash

ganache-cli --hostname 0.0.0.0 &

sleep 2

truffle migrate

tail -f /dev/null
