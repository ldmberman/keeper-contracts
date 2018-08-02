/* global artifacts */
const OceanMarket = artifacts.require('OceanMarket.sol')
const OceanAuth = artifacts.require('OceanAuth.sol')

const deployOceanAuth = (deployer) => {
    const MarketAddress = OceanMarket.address

    deployer.deploy(
        OceanAuth,
        MarketAddress
    )
}

module.exports = deployOceanAuth
