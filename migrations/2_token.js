/* global artifacts */

const Token = artifacts.require('./OceanToken.sol')

const token = (deployer) => {
    deployer.deploy(Token)
}

module.exports = token
