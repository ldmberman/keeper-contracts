/* global artifacts */

const Token = artifacts.require('OceanToken.sol')
const DLL = artifacts.require('dll/DLL.sol')
const AttributeStore = artifacts.require('attrstore/AttributeStore.sol')
const PLCRVoting = artifacts.require('PLCRVoting.sol')

const deployPLCR = (deployer) => {
    deployer.link(DLL, PLCRVoting)
    deployer.link(AttributeStore, PLCRVoting)

    deployer.deploy(PLCRVoting, Token.address)
}

module.exports = deployPLCR
