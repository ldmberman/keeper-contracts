/* global artifacts */

const Token = artifacts.require('OceanToken.sol')
const Market = artifacts.require('OceanMarket.sol')


const deployMarket = (deployer) => {
    const tokenAddress = Token.address

    deployer.deploy(
        Market,
        tokenAddress
    )
}
module.exports = deployMarket
