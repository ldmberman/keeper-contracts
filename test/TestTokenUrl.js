
var Token = artifacts.require("OceanToken.sol");
var Market =  artifacts.require("Market.sol");

var Web3 = require("web3");
var web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
var utils = require('web3-utils');

contract('Market', (accounts) => {
  describe('Test URL Token Access', () => {

    // support upto 50 assets and providers; each asset has one single provider at this time
    it('Should retreive access information', async () => {
        //const marketPlace = await Market.deployed();
        const token = await Token.deployed();
        const market = await Market.deployed();

        let assetId = 1;
        // 1. register provider and dataset
        await market.register(assetId, {from:accounts[0]});
        console.log("user [0] register a new data asset");

        // publish data  asset
        let _url = web3.fromUtf8("http://storage.amazon.com");
        let _token = web3.fromUtf8("aXsTSt");
        await market.publish(assetId, _url, _token, {from:accounts[0]});
        console.log("user [0] publish with url := http://storage.amazon.com and token = aXsTSt ")

        let info = await market.purchase( assetId, {from:accounts[1]});
        console.log("user [1] purchase the data asset");

        let urlInfo = await market.getAssetUrl( assetId, {from:accounts[1]});
        console.log("user [1] retreive the url of data asset := " + web3.toUtf8(urlInfo));

        let tokenInfo = await market.getAssetToken( assetId, {from:accounts[1]});
        console.log("user [1] retreive the url of data asset := " + web3.toUtf8(tokenInfo));


    });

  });
});
