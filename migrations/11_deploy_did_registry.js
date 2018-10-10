/* global artifacts */
const OceanDIDRegistry = artifacts.require('OceanDIDRegistry.sol')
const { saveDefinition } = require('./helper')

const oceanDIDRegistry = async (deployer, network) => {
    await deployer.deploy(
        OceanDIDRegistry
    )

    saveDefinition(network, OceanDIDRegistry)
}

module.exports = oceanDIDRegistry
