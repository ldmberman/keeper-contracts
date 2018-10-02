/* global artifacts */

const AttributeStore = artifacts.require('AttributeStore.sol')
const { saveDefinition } = require('./helper')

const attributeStore = async (deployer, network) => {
    await deployer.deploy(AttributeStore)
    saveDefinition(network, AttributeStore)
}

module.exports = attributeStore
