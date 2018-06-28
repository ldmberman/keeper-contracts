/* global artifacts */

const Registry = artifacts.require('Registry.sol')
const Token = artifacts.require('OceanToken.sol')
// const Parameterizer = artifacts.require('Parameterizer.sol');
const DLL = artifacts.require('dll/DLL.sol')
const AttributeStore = artifacts.require('attrstore/AttributeStore.sol')
const PLCRVoting = artifacts.require('PLCRVoting.sol')

const deployRegistry = (deployer) => {
    deployer.link(DLL, Registry)
    deployer.link(AttributeStore, Registry)

    const tokenAddress = Token.address
    deployer.deploy(Registry, tokenAddress, PLCRVoting.address) // , Parameterizer.address)
}

module.exports = deployRegistry
