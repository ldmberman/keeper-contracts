FROM node:9-alpine
MAINTAINER Ocean Protocol <devops@oceanprotocol.com>

RUN apk add --no-cache make gcc g++ python git bash

COPY . /opt/keeper-contracts
WORKDIR /opt/keeper-contracts

RUN npm -g config set user root && \
    npm install

RUN chmod +x /opt/keeper-contracts/scripts/keeper.sh
ENTRYPOINT ["/opt/keeper-contracts/scripts/keeper.sh"]
CMD [""]

# Expose listen port
EXPOSE 8545
