/* global artifacts */

const OceanToken = artifacts.require('OceanToken.sol')
const DLL = artifacts.require('DLL.sol')
const AttributeStore = artifacts.require('AttributeStore.sol')
const PLCRVoting = artifacts.require('PLCRVoting.sol')

const deployPLCR = async (deployer) => {
    await deployer.link(DLL, PLCRVoting)
    await deployer.link(AttributeStore, PLCRVoting)

    await deployer.deploy(PLCRVoting, OceanToken.address)
}

module.exports = deployPLCR
