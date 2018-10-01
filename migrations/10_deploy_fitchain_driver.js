/* global artifacts */
const Fitchain = artifacts.require('Fitchain.sol')
const { saveDefinition } = require('./helper')

const fitchain = async (deployer, network) => {
    await deployer.deploy(Fitchain)
    saveDefinition(network, Fitchain)
}

module.exports = fitchain
