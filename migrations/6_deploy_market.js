/* global artifacts */
const OceanRegistry = artifacts.require('OceanRegistry.sol')
const OceanToken = artifacts.require('OceanToken.sol')
const OceanMarket = artifacts.require('OceanMarket.sol')
const { saveDefinition } = require('./helper')

const deployOceanMarket = async (deployer, network) => {
    const tokenAddress = OceanToken.address
    const tcrAddress = OceanRegistry.address

    await deployer.deploy(
        OceanMarket,
        tokenAddress,
        tcrAddress
    )

    saveDefinition(network, OceanMarket)
}

module.exports = deployOceanMarket
