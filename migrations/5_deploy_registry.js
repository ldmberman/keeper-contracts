/* global artifacts */
const OceanRegistry = artifacts.require('OceanRegistry.sol')
const OceanToken = artifacts.require('OceanToken.sol')
const DLL = artifacts.require('DLL.sol')
const AttributeStore = artifacts.require('AttributeStore.sol')
const PLCRVoting = artifacts.require('PLCRVoting.sol')
const {saveDefinition} = require('./helper')

const oceanRegistry = async (deployer, network) => {
    await deployer.link(DLL, OceanRegistry)
    await deployer.link(AttributeStore, OceanRegistry)

    const tokenAddress = OceanToken.address
    await deployer.deploy(OceanRegistry, tokenAddress, PLCRVoting.address) // , Parameterizer.address)

    saveDefinition(network, OceanRegistry)
}

module.exports = oceanRegistry
