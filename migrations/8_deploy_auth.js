/* global artifacts */
const OceanMarket = artifacts.require('OceanMarket.sol')
const OceanAuth = artifacts.require('OceanAuth.sol')
const { saveDefinition } = require('./helper')

const oceanAuth = async (deployer, network) => {
    const marketAddress = OceanMarket.address

    await deployer.deploy(
        OceanAuth,
        marketAddress
    )

    saveDefinition(network, OceanAuth)
}

module.exports = oceanAuth
