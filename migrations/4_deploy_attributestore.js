/* global artifacts */

const AttributeStore = artifacts.require('AttributeStore.sol')

const attributeStore = async (deployer) => {
    await deployer.deploy(AttributeStore)
}

module.exports = attributeStore
