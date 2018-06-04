/* global artifacts */
const Token = artifacts.require("./OceanToken.sol");

module.exports = function(deployer) {
    deployer.deploy(Token);
};
