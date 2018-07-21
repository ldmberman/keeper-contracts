/* global artifacts */
const Market = artifacts.require('Market.sol')
const AccessControl = artifacts.require('Auth.sol')

const deployACL = (deployer) => {
    const MarketAddress = Market.address

    deployer.deploy(
        AccessControl,
        MarketAddress
    )
}
module.exports = deployACL
