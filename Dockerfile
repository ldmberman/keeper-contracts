FROM mhart/alpine-node:9
MAINTAINER Ocean Protocol <devops@oceanprotocol.com>

RUN apk add --no-cache make gcc g++ python git bash

COPY . /opt/plankton-keeper
# Install testrpc, truffle
WORKDIR /opt/plankton-keeper
RUN npm -g config set user root
RUN npm install -g truffle web3 ganache-cli
RUN npm install

RUN chmod +x /opt/plankton-keeper/scripts/keeper.sh
ENTRYPOINT ["/opt/plankton-keeper/scripts/keeper.sh"]
CMD [""]

# Expose listen port
EXPOSE 8545
