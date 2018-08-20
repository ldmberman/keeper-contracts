FROM node:8-alpine
MAINTAINER Ocean Protocol <devops@oceanprotocol.com>

RUN apk add --no-cache --update git python krb5 krb5-libs gcc make g++ krb5-dev bash

COPY . /keeper-contracts
WORKDIR /keeper-contracts

RUN npm install -g npm
RUN npm install -g ganache-cli truffle
RUN npm install

ENTRYPOINT "scripts/keeper.sh"

# Expose listen port
EXPOSE 8545
