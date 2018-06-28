/* global artifacts */

const Registry = artifacts.require('Registry.sol')
const Token = artifacts.require('OceanToken.sol')
const Market = artifacts.require('Market.sol')
// const PLCRVoting = artifacts.require('PLCRVoting.sol')

const deployMarket = (deployer) => {
    // deployer.link(DLL, Registry);
    // deployer.link(AttributeStore, Registry);
    const tokenAddress = Token.address
    const tcrAddress = Registry.address

    deployer.deploy(
        Market,
        tokenAddress,
        tcrAddress,
    )
}
module.exports = deployMarket
