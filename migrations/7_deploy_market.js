/* global artifacts */
const OceanRegistry = artifacts.require('OceanRegistry.sol')
const OceanToken = artifacts.require('OceanToken.sol')
const OceanMarket = artifacts.require('OceanMarket.sol')
const { saveDefinition } = require('./helper')

const oceanMarket = async (deployer, network) => {
    const tokenAddress = OceanToken.address
    const registryAddress = OceanRegistry.address

    await deployer.deploy(
        OceanMarket,
        tokenAddress,
        registryAddress
    )

    saveDefinition(network, OceanMarket)
}

module.exports = oceanMarket
