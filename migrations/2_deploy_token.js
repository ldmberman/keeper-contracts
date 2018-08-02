/* global artifacts */

const OceanToken = artifacts.require('./OceanToken.sol')

const deployOceanToken = (deployer) => {
    deployer.deploy(OceanToken)
}

module.exports = deployOceanToken
