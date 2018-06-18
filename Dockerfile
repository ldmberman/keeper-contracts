FROM ubuntu:16.04
MAINTAINER Ahmed Abdullah <ahmed@oceanprotocol.com>

# install software requirements
RUN apt-get update
RUN apt-get install -y software-properties-common curl git
RUN add-apt-repository ppa:ethereum/ethereum -y
RUN apt-get update
RUN apt-get install build-essential -y
RUN apt-get install -y gcc g++ libssl-dev libudev-dev pkg-config

# install nodejs, npm and build essentials
RUN curl -sL https://deb.nodesource.com/setup_9.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get install -y nodejs
RUN nodejs -v; npm -v
RUN apt-get install -y build-essential

COPY . /opt/plankton-keeper
# Install testrpc, truffle
WORKDIR /opt/plankton-keeper
RUN rm -rf node_modules
RUN npm cache clear --force
RUN npm -g config set user root
RUN npm install -g truffle web3 ganache-cli
RUN npm install --unsafe-perm



RUN chmod +x /opt/plankton-keeper/scripts/keeper.sh

ENTRYPOINT ["/opt/plankton-keeper/scripts/keeper.sh"]
CMD [""]

# Expose listen port
EXPOSE 8545
