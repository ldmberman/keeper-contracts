/* global artifacts */
const OceanRegistry = artifacts.require('OceanRegistry.sol')
const OceanToken = artifacts.require('OceanToken.sol')
const OceanMarket = artifacts.require('OceanMarket.sol')

const deployOceanMarket = (deployer) => {
    const tokenAddress = OceanToken.address
    const tcrAddress = OceanRegistry.address

    deployer.deploy(
        OceanMarket,
        tokenAddress,
        tcrAddress
    )
}

module.exports = deployOceanMarket
