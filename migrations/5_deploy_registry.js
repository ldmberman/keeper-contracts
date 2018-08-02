/* global artifacts */

const Registry = artifacts.require('OceanRegistry.sol')
const Token = artifacts.require('OceanToken.sol')
const DLL = artifacts.require('DLL.sol')
const AttributeStore = artifacts.require('AttributeStore.sol')
const PLCRVoting = artifacts.require('PLCRVoting.sol')

const deployRegistry = (deployer) => {
    deployer.link(DLL, Registry)
    deployer.link(AttributeStore, Registry)

    const tokenAddress = Token.address
    deployer.deploy(Registry, tokenAddress, PLCRVoting.address) // , Parameterizer.address)
}

module.exports = deployRegistry
