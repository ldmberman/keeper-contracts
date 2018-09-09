/* global artifacts */
const OceanDispute = artifacts.require('OceanDispute.sol')
const OceanMarket = artifacts.require('OceanMarket.sol')
const OceanRegistry = artifacts.require('OceanRegistry.sol')
const { saveDefinition } = require('./helper')

const oceanDispute = async (deployer, network) => {

    await deployer.deploy(
        OceanDispute,
        OceanMarket.address,
        OceanRegistry.address
    )

    saveDefinition(network, OceanDispute)
}

module.exports = oceanDispute
