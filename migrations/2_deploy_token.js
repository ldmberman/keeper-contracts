/* global artifacts */
const OceanToken = artifacts.require('./OceanToken.sol')
const { saveDefinition } = require('./helper')

const deployOceanToken = async (deployer, network) => {
    await deployer.deploy(OceanToken)

    saveDefinition(network, OceanToken)
}

module.exports = deployOceanToken
