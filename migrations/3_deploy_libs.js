/* global artifacts */

const DLL = artifacts.require('DLL.sol')
const AttributeStore = artifacts.require('AttributeStore.sol')

const libs = async (deployer) => {
    await deployer.deploy(DLL)
    await deployer.deploy(AttributeStore)
}

module.exports = libs
