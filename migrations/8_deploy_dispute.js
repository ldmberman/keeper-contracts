/* global artifacts */
const OceanDispute = artifacts.require('OceanDispute.sol')
const OceanMarket = artifacts.require('OceanMarket.sol')
const OceanRegistry = artifacts.require('OceanRegistry.sol')
const DLL = artifacts.require('DLL.sol')
const AttributeStore = artifacts.require('AttributeStore.sol')
const PLCRVoting = artifacts.require('PLCRVoting.sol')
const { saveDefinition } = require('./helper')

const oceanDispute = async (deployer, network) => {
    deployer.link(DLL, OceanDispute)
    deployer.link(AttributeStore, OceanDispute)

    await deployer.deploy(
        OceanDispute,
        OceanMarket.address,
        OceanRegistry.address,
        PLCRVoting.address
    )

    saveDefinition(network, OceanDispute)
}

module.exports = oceanDispute
