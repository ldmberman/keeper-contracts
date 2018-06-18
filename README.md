[![plankton-keeper](doc/img/repo-banner@2x.png)](https://oceanprotocol.com)

> 💧 Integration of TCRs, CPM and Ocean Tokens
> [oceanprotocol.com](https://oceanprotocol.com)

[![Build Status](https://travis-ci.com/oceanprotocol/plankton-keeper.svg?token=soMi2nNfCZq19zS1Rx4i&branch=master)](https://travis-ci.com/oceanprotocol/plankton-keeper)

Ocean Keeper implementation where we put the following modules together:

* **TCRs**: users create challenges and resolve them through voting to maintain registries;
* **Ocean Tokens**: the intrinsic tokens circulated inside Ocean network, which is used in the voting of TCRs;
* **Curated Proofs Market**: the core marketplace where people can transact with each other and curate assets through staking with Ocean tokens.

## Table of Contents

  - [Get Started](#get-started)
  - [Testing](#testing)
  - [Documentation](#documentation)
  - [Contributing](#contributing)
  - [License](#license)

---

## Get Started

As a pre-requisite, you need Node.js >= v6.11.5.

Clone the project and install all dependencies:

```bash
git clone git@github.com:oceanprotocol/plankton-keeper.git
cd plankton-keeper/

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

Note:
* there are `Error: run out of gas` because we try to deploy so many contracts as one single transaction. Tune the `gas` value in `truffle.js` file to make them run through.
* we enable the solc optimizer to reduce the gas cost of deployment. It can now be deployed with less gas limit such as `gas = 5000000`
* no need to update the `from : 0x3424ft...` in `truffle.js` and it will use the first account in testRPC or ganache-cli by default.

## Testing

Run tests with `truffle test`, e.g.:

```bash
truffle test test/registry.js
```

## Documentation

* [**Main Documentation: TCR and CPM and Ocean Tokens**](doc/)
* [Architecture](doc/files/Smart-Contract-UML-class-diagram.pdf)

## Contributing

Plankton Keeper uses GitHub as a means for maintaining and tracking issues and source code development.

If you would like to contribute, please fork this code, fix the issue then commit, finally send a pull request to maintainers in order to review your changes. 

Ocean Protocol uses [C4 Standard process](https://github.com/unprotocols/rfc/blob/master/1/README.md) to manage changes in the source code.  Find here more details about [Ocean C4 OEP](https://github.com/oceanprotocol/OEPs/tree/master/1).

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