#!/bin/bash

ganache-cli  > /dev/null 1> /dev/null &

sleep 5

truffle migrate

tail -f /dev/null
