/* global artifacts */

const OceanRegistry = artifacts.require('OceanRegistry.sol')
const OceanToken = artifacts.require('OceanToken.sol')
const DLL = artifacts.require('DLL.sol')
const AttributeStore = artifacts.require('AttributeStore.sol')
const PLCRVoting = artifacts.require('PLCRVoting.sol')

const deployOceanRegistry = (deployer) => {
    deployer.link(DLL, OceanRegistry)
    deployer.link(AttributeStore, OceanRegistry)

    const tokenAddress = OceanToken.address
    deployer.deploy(OceanRegistry, tokenAddress, PLCRVoting.address) // , Parameterizer.address)
}

module.exports = deployOceanRegistry
