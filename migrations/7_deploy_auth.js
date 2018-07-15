/* global artifacts */
const Market = artifacts.require('Market.sol')
const AccessControl = artifacts.require('ACL.sol')

const deployACL = (deployer) => {
    const MarketAddress = Market.address

    deployer.deploy(
        AccessControl,
        MarketAddress
    )
}
module.exports = deployACL
