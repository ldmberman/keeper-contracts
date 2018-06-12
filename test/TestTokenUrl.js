
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
        let _url = web3.fromUtf8("https://testocnfiles.blob.core.windows.net/testfiles/testzkp.pdf?sp=r&st=2018-06-11T11:52:03Z&se=2018-06-11T19:52:03Z&spr=https&sv=2017-11-09&sig=6HFajCLIjCL91pJcACcyYhaDi8Su61L0DXMcpZk8rnw%3D&sr=b");
        let _token = web3.fromUtf8("https://testocnfiles.blob.core.windows.net/testfiles/testzkp.pdf?sp=r&st=2018-06-11T11:52:03Z&se=2018-06-11T19:52:03Z&spr=https&sv=2017-11-09&sig=6HFajCLIjCL91pJcACcyYhaDi8Su61L0DXMcpZk8rnw%3D&sr=b");
        await market.publish(assetId, _url, _token, {from:accounts[0]});
        console.log("user [0] publish with url := https://testocnfiles.blob.core.windows.net/testfiles/testzkp.pdf?sp=r&st=2018-06-11T11:52:03Z&se=2018-06-11T19:52:03Z&spr=https&sv=2017-11-09&sig=6HFajCLIjCL91pJcACcyYhaDi8Su61L0DXMcpZk8rnw%3D&sr=b and token = aXsTSt ")

        let info = await market.purchase( assetId, {from:accounts[1]});
        console.log("user [1] purchase the data asset");

        let urlInfo = await market.getAssetUrl( assetId, {from:accounts[1]});
        console.log("user [1] retreive the url of data asset := " + web3.toUtf8(urlInfo));

        let tokenInfo = await market.getAssetToken( assetId, {from:accounts[1]});
        console.log("user [1] retreive the url of data asset := " + web3.toUtf8(tokenInfo));


    });

  });
});
