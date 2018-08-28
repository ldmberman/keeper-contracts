#!/bin/bash

parity --chain=kovan \
    --jsonrpc-apis web3,eth,net,parity,traces,rpc,personal \
    --jsonrpc-cors http://localhost:3000 \
    --unlock=0x023bdc21d00dd7c51aefb34ce00ac3281f307975 \
    --password="/Users/sebastian/ssh/parity_pass"
