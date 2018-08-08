[![banner](doc/img/repo-banner@2x.png)](https://oceanprotocol.com)

<h1 align="center">keeper-contracts</h1>

> 💧 Integration of TCRs, CPM and Ocean Tokens in Solidity
> [oceanprotocol.com](https://oceanprotocol.com)

[![Build Status](https://travis-ci.com/oceanprotocol/keeper-contracts.svg?token=soMi2nNfCZq19zS1Rx4i&branch=master)](https://travis-ci.com/oceanprotocol/keeper-contracts)
[![js ascribe](https://img.shields.io/badge/js-ascribe-39BA91.svg)](https://github.com/ascribe/javascript)

Ocean Keeper implementation where we put the following modules together:

* **TCRs**: users create challenges and resolve them through voting to maintain registries;
* **Ocean Tokens**: the intrinsic tokens circulated inside Ocean network, which is used in the voting of TCRs;
* **Marketplace**: the core marketplace where people can transact with each other with Ocean tokens.

## Table of Contents

  - [Get Started](#get-started)
     - [Docker](#docker)
     - [Local development](#local-development)
  - [Libraries](#libraries)
  - [Testing](#testing)
     - [Code Linting](#code-linting)
  - [Documentation](#documentation)
  - [Contributing](#contributing)
  - [Prior Art](#prior-art)
  - [License](#license)

---

## Get Started

For local developmenty you can either use Docker, or setup the development environment on your machine.

### Docker

The most simple way to get started is with Docker:

```bash
git clone git@github.com:oceanprotocol/keeper-contracts.git
cd keeper-contracts/

docker build -t keeper-contracts:0.1 .
docker run -d -p 8545:8545 keeper-contracts:0.1
```

Which will expose the Ethereum RPC client with all contracts loaded under localhost:8545, which you can add to your `truffle.js`:

```js
module.exports = {
    networks: {
        development: {
            host: 'localhost',
            port: 8545,
            network_id: '*',
            gas: 6000000
        },
    }
}
```

### Local development

As a pre-requisite, you need Node.js >= v8.11.1.

Clone the project and install all dependencies:

```bash
git clone git@github.com:oceanprotocol/keeper-contracts.git
cd keeper-contracts/

# install dependencies
npm i

# install RPC client globally
npm install -g ganache-cli
```

Compile the solidity contracts:

```bash
truffle compile
```

In a new terminal, launch an Ethereum RPC client, e.g. [ganache-cli](https://github.com/trufflesuite/ganache-cli):

```bash
ganache-cli
```

Switch back to your other terminal and deploy the contracts:

```bash
truffle migrate

# for redeployment run this instead
truffle migrate --reset
```

### Testnet deployment

Follow the steps for local deployment. Make sure that the address `0x372481Ab4BaB2e06b6737760C756bB238E9024a4` is having enough (~1) Ether. 

If you managed to deploy the contracts locally do:

```bash
export INFURA_TOKEN=<your infura token>
truffle migrate --network kovan
```

The transaction should show up on: `https://kovan.etherscan.io/address/0x372481ab4bab2e06b6737760c756bb238e9024a4

## Libraries

To facilitate the integration of the Ocean Keeper Smart Contracts, Python and Javascript libraries are ready to be integrated. Those libraries include the Smart Contract ABI's.
Using these libraries helps to avoid compiling the Smart Contracts and copying the ABI's manually to your project. In that way the integration is cleaner and easier.
The libraries provided currently are:

* Javascript NPM package - As part of the [@oceanprotocol NPM organization](https://www.npmjs.com/settings/oceanprotocol/packages), the [NPM Keeper Contracts package](https://www.npmjs.com/package/@oceanprotocol/keeper-contracts) provides the ABI's to be imported from your Javascript code.
* Python Pypi package - The [Pypi Keeper Contracts package](https://pypi.org/project/keeper-contracts/) provides the same ABI's to be used from Python


## Testing

Run tests with `truffle test`, e.g.:

```bash
truffle test test/TestAuth.js
```

### Code Linting

Linting is setup for JavaScript with [ESLint](https://eslint.org) & Solidity with [Solium](https://github.com/duaraghav8/Solium).

Code style is enforced through the CI test process, builds will fail if there're any linting errors.

## Documentation

* [**Main Documentation: TCR, Market and Ocean Tokens**](doc/)
* [Architecture (pdf)](doc/files/Smart-Contract-UML-class-diagram.pdf)
* [Packaging of libraries](docs/packaging.md)

## Contributing

We use GitHub as a means for maintaining and tracking issues and source code development.

If you would like to contribute, please fork this repository, do work in a feature branch, and finally open a pull request for maintainers to review your changes.

Ocean Protocol uses [C4 Standard process](https://github.com/unprotocols/rfc/blob/master/1/README.md) to manage changes in the source code.  Find here more details about [Ocean C4 OEP](https://github.com/oceanprotocol/OEPs/tree/master/1).

## Prior Art

This project builds on top of the work done in open source projects:

- [ConsenSys/PLCRVoting](https://github.com/ConsenSys/PLCRVoting)
- [skmgoldin/tcr](https://github.com/skmgoldin/tcr)
- [OpenZeppelin/openzeppelin-solidity](https://github.com/OpenZeppelin/openzeppelin-solidity)


## License

```
Copyright 2018 Ocean Protocol Foundation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
