/* global artifacts */

const DLL = artifacts.require('DLL.sol')

const dll = async (deployer) => {
    await deployer.deploy(DLL)
}

module.exports = dll
