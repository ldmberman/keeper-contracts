/* global artifacts */
const OceanToken = artifacts.require('OceanToken.sol')
const OceanExchange = artifacts.require('OceanExchange.sol')
const { saveDefinition } = require('./helper')

const oceanExchange = async (deployer, network) => {
    const tokenAddress = OceanToken.address

    await deployer.deploy(
        OceanExchange,
        tokenAddress
    )

    saveDefinition(network, OceanExchange)
}

module.exports = oceanExchange
