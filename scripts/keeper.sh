#!/bin/bash
export LC_ALL=$(locale -a | grep en_US)
export LANG=$(locale -a | grep en_US)
ganache-cli  > /dev/null 1> /dev/null &
sleep 5
truffle compile
truffle migrate --network development
tail -f /dev/null