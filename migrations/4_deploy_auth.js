/* global artifacts */
const Market = artifacts.require('OceanMarket.sol')
const AccessControl = artifacts.require('OceanAuth.sol')

const deployACL = (deployer) => {
    const MarketAddress = Market.address

    deployer.deploy(
        AccessControl,
        MarketAddress
    )
}
module.exports = deployACL
