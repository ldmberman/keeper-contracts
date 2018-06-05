//var utils = require("../scripts/utils");
var Token = artifacts.require("OceanToken.sol");
var Market =  artifacts.require("Market.sol");

function wait(ms){
   var start = new Date().getTime();
   var end = start;
   while(end < start + ms) {
     end = new Date().getTime();
  }
}

contract('Market', (accounts) => {
  describe('Test User stories', () => {


  // support upto 50 assets and providers; each asset has one single provider at this time
  it('Should walk through typical user story', async () => {
      //const marketPlace = await Market.deployed();
      const token = await Token.deployed();
      const market = await Market.deployed();


      let assetId = 1;
      // 1. register provider and dataset
      await market.register(assetId, {from:accounts[0]});

      // publish data  asset
      let _url = "http://aws.com";
      let _token = "aXsTSt";
      await market.publish(assetId, _url, _token, {from:accounts[0]});


      // 2. provider request initial tokens 2000
      await market.requestTokens(2000, {from:accounts[0]});
      const bal1   = await token.balanceOf.call(accounts[0]);
      //assert.equal(bal1.toNumber(), 2000,"User should have 2000 OCN tokens now.");
      console.log("User has " + bal1.toNumber() + " Ocean tokens now.")

      // 3. provider transfer OCN tokens into Market and buy drops
      // testing: 125 OCN = 1000 drops;  20 OCN = 200 drops
      let ntokens = 10;   // number of drops to purchase
      // calculate number of OCN tokens required for tx
      await token.approve(market.address, ntokens, { from: accounts[0]} );
      // transfer 100 OCN tokens to market and buy drops
      await market.buyDrops(assetId, ntokens, {from:accounts[0]});
      console.log("buy drops successful!");
      const bal2   = await token.balanceOf.call(accounts[0]);
      console.log("provider has balance of OCN := " + bal2.valueOf());
      //assert.equal(bal2.toNumber(), 2000 - ntokens,"User should have 1875 OCN tokens now.");
      const drops1 = await market.dropsBalance(assetId, {from:accounts[0]});
      console.log("User [0] should have " + drops1.toNumber() + " drops now.");
      //assert.equal(drops1.toNumber(), ndrops,"User should have 1000 drops now.");
      //const tokenBalanceee = await market.tokenBalance.call({from:accounts[0]});
      //console.log("1. provider has escrow balance with reward credit := " + tokenBalanceee.toNumber() + " Ocean tokens after serveRequest");

      // another use purchase drops
      await market.requestTokens(2000, {from:accounts[1]});
      await token.approve(market.address, ntokens, { from: accounts[1]} );
      // transfer 100 OCN tokens to market and buy drops
      await market.buyDrops(assetId, ntokens, {from:accounts[1]});
      const drops2 = await market.dropsBalance(assetId, {from:accounts[1]});
      console.log("User [0] should have " + drops2.toNumber() + " drops now.");


      // 4. user[1] purchase the dataset - before purcahse, new block reward shall be claimed by marketplace
      const tokenBalanceBefore = await token.balanceOf.call(market.address);
      console.log("provider has escrow balance with reward credit := " + tokenBalanceBefore.toNumber() + " Ocean tokens");
      wait(30000);
      await market.mintToken({from:accounts[0]});
      const bal3 = await token.balanceOf.call(market.address);
      console.log("market balance with emitted tokens := " + bal3.toNumber());

      await market.purchase(assetId, {from:accounts[1]});
      const tokenBalanceAfter = await token.balanceOf.call(market.address);
      console.log("provider has escrow balance with reward credit := " + tokenBalanceAfter.toNumber() + " Ocean tokens");

      // 7. provider sell Drops for Ocean TOKENS
      await market.sellDrops(assetId, drops1.valueOf(), {from:accounts[0]});
      const tokenBalance1 = await market.tokenBalance.call({from:accounts[0]});
      console.log("provider has escrow balance of Ocean tokens := " + tokenBalance1.toNumber());

      // 8. withdraw Ocean tokens
      await market.withdraw({from:accounts[0]});
      const bal4  = await token.balanceOf.call(accounts[0]);
      console.log("provider has balance of OCN := " + bal4.toNumber());

    });

  });
});
