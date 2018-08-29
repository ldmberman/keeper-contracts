/* global artifacts */

const OceanToken = artifacts.require('OceanToken.sol')
const DLL = artifacts.require('DLL.sol')
const AttributeStore = artifacts.require('AttributeStore.sol')
const PLCRVoting = artifacts.require('PLCRVoting.sol')

const pLCRVoting = async (deployer) => {
    deployer.link(DLL, PLCRVoting)
    deployer.link(AttributeStore, PLCRVoting)

    await deployer.deploy(PLCRVoting, OceanToken.address)
}

module.exports = pLCRVoting
