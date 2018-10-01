/* global artifacts */

const DLL = artifacts.require('DLL.sol')
const { saveDefinition } = require('./helper')

const dll = async (deployer, network) => {
    await deployer.deploy(DLL)
    saveDefinition(network, DLL)
}

module.exports = dll
