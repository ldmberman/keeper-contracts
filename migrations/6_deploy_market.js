/* global artifacts */

const Registry = artifacts.require('OceanRegistry.sol')
const Token = artifacts.require('OceanToken.sol')
const Market = artifacts.require('OceanMarket.sol')

const deployMarket = (deployer) => {
    const tokenAddress = Token.address
    const tcrAddress = Registry.address

    deployer.deploy(
        Market,
        tokenAddress,
        tcrAddress
    )
}
module.exports = deployMarket
