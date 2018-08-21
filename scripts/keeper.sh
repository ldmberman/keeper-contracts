#!/bin/bash

ganache-cli -b 2 --hostname 0.0.0.0 &

sleep 2

truffle migrate

tail -f /dev/null
