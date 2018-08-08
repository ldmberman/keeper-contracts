/* global artifacts */

const DLL = artifacts.require('DLL.sol')
const AttributeStore = artifacts.require('AttributeStore.sol')

const deployLibs = (deployer) => {
    deployer.deploy(DLL)
    deployer.deploy(AttributeStore)
}

module.exports = deployLibs
