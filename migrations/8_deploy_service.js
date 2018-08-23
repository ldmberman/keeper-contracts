/* global artifacts */
const OceanService = artifacts.require('OceanService.sol')
const { saveDefinition } = require('./helper')

const deployOceanService = async (deployer, network) => {

    await deployer.deploy(
        OceanService
    )

    saveDefinition(network, OceanService)
}

module.exports = deployOceanService
