/* global artifacts */
const OceanMarket = artifacts.require('OceanMarket.sol')
const OceanAuth = artifacts.require('OceanAuth.sol')
const { saveDefinition } = require('./helper')

const deployOceanAuth = async (deployer, network) => {
    const MarketAddress = OceanMarket.address

    await deployer.deploy(
        OceanAuth,
        MarketAddress
    )

    saveDefinition(network, OceanAuth)
}

module.exports = deployOceanAuth
