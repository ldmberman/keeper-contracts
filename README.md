# Plankton Keeper
Ocean Protocol token engineering Layer

[![Build Status](https://travis-ci.com/oceanprotocol/plankton-keeper.svg?token=soMi2nNfCZq19zS1Rx4i&branch=master)](https://travis-ci.com/oceanprotocol/plankton-keeper)

# Getting started

Node.js (>= v6.11.5)  

Clone project and install all dependencies:

```bash
git clone git@github.com:oceanprotocol/plankton-keeper.git
cd plankton-keeper/

# install dependencies
npm i
```

Compile the solidity contracts:

```bash
truffle compile
```

Start TestRPC:

In a new terminal, launch an Ethereum RPC client, e.g. [ganache-cli](https://github.com/trufflesuite/ganache-cli):
```bash
npm install -g ganache-cli
ganache-cli
```

Switch back to your other terminal and deploy the contracts:

```bash
truffle migrate

# for redeployment run this instead
truffle migrate --reset
```

Run tests with <code>truffle test</code>, e.g.:

```bash
truffle test test/registry.js
```

You can find here more details about the [Architecture](doc/files/Smart-Contract-UML-class-diagram.pdf) and, [TCR and CPM and ocean tokens docs](doc/README.md) 


# Contributing

Plankton keeper uses github as a means for maintaining and tracking issues and source code development.
If you would like to contribute to <code>plankton-keeper</code>, please fork this code, fix the issue then commit, finally send 
a pull request to maintainers in order to review your changes. Ocean protocol uses [C4 Standard process](https://github.com/unprotocols/rfc/blob/master/1/README.md) to manage changes in the source code. Find here more details about [Ocean C4 OEP](https://github.com/oceanprotocol/OEPs/tree/master/1).

# License

The Plankton-keeper library is licensed under the [Apache 2.0 License](LICENSE.txt).