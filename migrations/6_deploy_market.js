const Registry = artifacts.require('Registry.sol');
const Token = artifacts.require('OceanToken.sol');
const Market = artifacts.require('Market.sol');
const PLCRVoting = artifacts.require('PLCRVoting.sol');

module.exports = function(deployer) {
  //deployer.link(DLL, Registry);
  //deployer.link(AttributeStore, Registry);
  let tokenAddress = Token.address;
  let tcrAddress = Registry.address;

  deployer.deploy(
    Market,
    tokenAddress,
    tcrAddress,
    {gas: 6600000}
  );
};
