/* global artifacts */

const DLL = artifacts.require('dll/DLL.sol')
const AttributeStore = artifacts.require('attrstore/AttributeStore.sol')

const deployLibs = (deployer) => {
    deployer.deploy(DLL)
    deployer.deploy(AttributeStore)
}

module.exports = deployLibs
