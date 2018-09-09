/* global artifacts */
const OceanMarket = artifacts.require('OceanMarket.sol')
const OceanAuth = artifacts.require('OceanAuth.sol')
const OceanDispute = artifacts.require('OceanDispute.sol')
const { saveDefinition } = require('./helper')

const oceanAuth = async (deployer, network) => {

    await deployer.deploy(
        OceanAuth,
        OceanMarket.address,
        OceanDispute.address
    )

    saveDefinition(network, OceanAuth)
}

module.exports = oceanAuth
