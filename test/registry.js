/* global artifacts, assert, contract, describe, it */
/* eslint-disable no-console, max-len */

const Registry = artifacts.require('Registry.sol')
const Token = artifacts.require('OceanToken.sol')
const Market = artifacts.require('Market.sol')
const PLCRVoting = artifacts.require('PLCRVoting.sol')
const BN = require('bignumber.js')
const Web3 = require('web3')
const utils = require('./utils.js')

const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'))

const bigTen = number => new BN(number.toString(10), 10)

function wait(ms) {
    const start = new Date().getTime()
    let end = start
    while (end < start + ms) {
        end = new Date().getTime()
    }
}

contract('Market', (accounts) => {
    describe('Test User stories', () => {
        it('Should request tokens', async () => {
            const token = await Token.deployed()
            const market = await Market.deployed()
            const tcr = await Registry.deployed()
            const plcr = await PLCRVoting.deployed()

            // request initial fund
            await market.requestTokens(1000, { from: accounts[0] })
            await market.requestTokens(1000, { from: accounts[1] })
            await market.requestTokens(1000, { from: accounts[2] })
            await market.requestTokens(1000, { from: accounts[3] })
            await market.requestTokens(1000, { from: accounts[4] })
            const bal1 = await token.balanceOf.call(accounts[0])
            console.log(`Step 0: User has ${bal1.toNumber()} Ocean tokens now.`)

            // approve tokens to be transferred into marketplace
            await token.approve(market.address, 1000, { from: accounts[0] })
            await token.approve(market.address, 1000, { from: accounts[1] })
            await token.approve(market.address, 1000, { from: accounts[2] })
            await token.approve(market.address, 1000, { from: accounts[3] })
            await token.approve(market.address, 1000, { from: accounts[4] })

            // approve tokens to be transferred into Registry
            await token.approve(tcr.address, 1000, { from: accounts[0] })
            await token.approve(tcr.address, 1000, { from: accounts[1] })
            await token.approve(tcr.address, 1000, { from: accounts[2] })
            await token.approve(tcr.address, 1000, { from: accounts[3] })
            await token.approve(tcr.address, 1000, { from: accounts[4] })

            // approve tokens to be transferred into voting
            await token.approve(plcr.address, 1000, { from: accounts[0] })
            await token.approve(plcr.address, 1000, { from: accounts[1] })
            await token.approve(plcr.address, 1000, { from: accounts[2] })
            await token.approve(plcr.address, 1000, { from: accounts[3] })
            await token.approve(plcr.address, 1000, { from: accounts[4] })
        })


        /*
  it('should successfully challenge an application', async () => {
      const registry = await Registry.deployed();
      const token = Token.at(await registry.token.call());
      const listing = utils.getListingHash('failure.net');

      const challengerStartingBalance = await token.balanceOf.call(accounts[0]);

      await utils.as(accounts[0], registry.apply, listing, 10, '');
      await utils.challengeAndGetPollID(listing, accounts[1]);
      //await utils.increaseTime(10 + 10 + 1);
      wait(21000);
      await registry.updateStatus(listing);

      const isWhitelisted = await registry.isWhitelisted.call(listing);
      assert.strictEqual(isWhitelisted, false, 'An application which should have failed succeeded');

      const challengerFinalBalance = await token.balanceOf.call(accounts[1]);
      // Note edge case: no voters, so challenger gets entire stake
      const expectedFinalBalance =
        challengerStartingBalance.add(new BN(10, 10));
      assert.strictEqual(
        challengerFinalBalance.toString(10), expectedFinalBalance.toString(10),
        'Reward not properly disbursed to challenger',
      );
    });


  it('should apply, fail challenge, and reject listing', async () => {
      const registry = await Registry.deployed();
      const token = Token.at(await registry.token.call());
      const challengerStartingBalance = await token.balanceOf.call(accounts[1]);

      const applicantBeginBalance = await token.balanceOf.call(accounts[0]);
      console.log("starting balance of applicant := " + applicantBeginBalance);

      const challengerBeginBalance = await token.balanceOf.call(accounts[1]);
      console.log("starting balance of challenger := " + challengerBeginBalance);

      const listing = utils.getListingHash('failChallenge.net'); // listing to apply with
      await registry.apply(listing, 10, '', { from: accounts[0] });
      console.log("applicant submits an application of listing");
      await registry.challenge(listing, '', { from: accounts[1]});
      console.log("challenger creates an challenge of listing");

      wait(21000);
      console.log("application expires after 20 seconds");
      await registry.updateStatus(listing);

      // should not have been added to whitelist
      const result = await registry.isWhitelisted(listing);
      assert.strictEqual(result, false, 'listing should not be whitelisted');

      const challengerFinalBalance = await token.balanceOf.call(accounts[1]);
      // Note edge case: no voters, so challenger gets entire stake
      const expectedFinalBalance =
        challengerStartingBalance.add(new BN(10, 10));
      assert.strictEqual(
        challengerFinalBalance.toString(10), expectedFinalBalance.toString(10),
        'Reward not properly disbursed to challenger',
      );

      const applicantAfterBalance = await token.balanceOf.call(accounts[0]);
      console.log("final balance of applicant := " + applicantAfterBalance);

      const challengerAfterBalance = await token.balanceOf.call(accounts[1]);
      console.log("final balance of challenger := " + challengerAfterBalance);

      /// market place check results
      const market = await Market.deployed();
      const isListed1 = await market.checkListingStatus(listing, { from: accounts[0]});
      assert.strictEqual(isListed1, false, 'Listing should be whitelisted');
      console.log("marketplace queries the voting result of listing");
    });
    */

        it('should apply, pass challenge, and whitelist listing', async () => {
            const registry = await Registry.deployed()
            const voting = await utils.getVoting()
            const token = await Token.deployed()
            const listing = utils.getListingHash('passChallenge.net')
            const minDeposit = bigTen(10)
            const market = await Market.deployed()

            const assetId = 1
            // 1. register provider and dataset
            await market.register(assetId, { from: accounts[0] })
            const _url = web3.fromUtf8('http://aws.amazon.com')
            const _token = web3.fromUtf8('aXsTSt')
            await market.publish(assetId, _url, _token, { from: accounts[0] })

            const applicantBeginBalance = await token.balanceOf.call(accounts[0])
            console.log(`starting balance of applicant := ${applicantBeginBalance}`)

            const challengerBeginBalance = await token.balanceOf.call(accounts[1])
            console.log(`starting balance of challenger := ${challengerBeginBalance}`)

            const voterBeginBalance = await token.balanceOf.call(accounts[1])
            console.log(`starting balance of voter := ${voterBeginBalance}`)

            await utils.as(accounts[0], registry.apply, listing, minDeposit, '')
            console.log('applicant submits an application of listing')

            // Challenge and get back the pollID
            const pollID = await utils.challengeAndGetPollID(listing, accounts[1])
            // const startT = await voting.queryTS.call()
            // console.log("starting time of commit period:=" + startT);

            // Make sure it's cool to commit
            const cpa = await voting.commitPeriodActive.call(pollID)
            assert.strictEqual(cpa, true, 'Commit period should be active')
            console.log('Commit period should be open now')

            // Virgin commit
            const tokensArg = 10
            const salt = 420
            const voteOption = 1
            await utils.commitVote(pollID, voteOption, tokensArg, salt, accounts[2]) // voter
            console.log('voter has voted for the listing')

            const numTokens = await voting.getNumTokens.call(accounts[2], pollID) // voter
            assert.strictEqual(numTokens.toString(10), tokensArg.toString(10), 'Should have committed the correct number of tokens')

            // Reveal
            // await utils.increaseTime(10 + 1);
            const CET = await voting.queryCommitEndDate.call(pollID)
            // console.log("end of commit period time should be :=" + CET);

            let endT = 0

            /* eslint-disable no-await-in-loop, no-constant-condition */
            while (true) {
                wait(2000)
                endT = await voting.queryTS.call()
                // console.log("current timestamp :=" + endT);

                await market.register(endT, { from: accounts[0] })

                if (endT >= CET) {
                    break
                }
            }
            /* eslint-enable no-await-in-loop */

            // Make sure commit period is inactive
            const commitPeriodActive = await voting.commitPeriodActive.call(pollID)
            assert.strictEqual(commitPeriodActive, false, 'Commit period should be inactive')
            console.log('Commit period should be closed')
            // Make sure reveal period is active
            let rpa = await voting.revealPeriodActive.call(pollID)
            assert.strictEqual(rpa, true, 'Reveal period should be active')
            console.log('Reveal period should be open now')
            // const startRT = await voting.queryTS.call()
            // console.log("starting time of reveal period:=" + startRT);

            await voting.revealVote(pollID, voteOption, salt, { from: accounts[2] }) // voter

            // End reveal period
            // await utils.increaseTime(paramConfig.revealStageLength + 1);
            // wait(11000);
            const RET = await voting.queryRevealEndDate.call(pollID)
            // console.log("end of reveal period time should be :=" + RET);

            /* eslint-disable no-await-in-loop */
            while (true) {
                wait(2000)
                endT = await voting.queryTS.call()
                // console.log("current timestamp :=" + endT);

                await market.register(endT, { from: accounts[0] })

                if (endT >= RET) {
                    break
                }
            }
            /* eslint-enable no-await-in-loop */

            rpa = await voting.revealPeriodActive.call(pollID)
            assert.strictEqual(rpa, false, 'Reveal period should not be active')
            console.log('Reveal period should be closed')
            // updateStatus
            const pollResult = await voting.isPassed.call(pollID)
            assert.strictEqual(pollResult, true, 'Poll should have passed')
            console.log('Voting result is revealed')

            // Add to whitelist
            await registry.updateStatus(listing)
            const result = await registry.isWhitelisted(listing)
            assert.strictEqual(result, true, 'Listing should be whitelisted')
            console.log('Listing is whitelisted now.')

            const isListed2 = await market.checkListingStatus(listing, assetId, { from: accounts[0] })
            assert.strictEqual(isListed2, true, 'Listing should be whitelisted')

            const voterBeforeClaim = await token.balanceOf.call(accounts[2])
            console.log(`the balance of voter before claimReward ${voterBeforeClaim.toNumber()} Ocean tokens now.`)


            // claim and withdraw Rewards
            // const VoterReward = await registry.voterReward(accounts[2], pollID, '420')
            await utils.as(accounts[2], registry.claimReward, pollID, '420')

            // Alice withdraws her voting rights
            await utils.as(accounts[2], voting.withdrawVotingRights, '10')

            const bal2 = await token.balanceOf.call(accounts[0])
            console.log(`final balance of applicant ${bal2.toNumber()} Ocean tokens now.`)

            const bal3 = await token.balanceOf.call(accounts[1])
            console.log(`final balance of challenger ${bal3.toNumber()} Ocean tokens now.`)


            const bal4 = await token.balanceOf.call(accounts[2])
            console.log(`final balance of voter ${bal4.toNumber()} Ocean tokens now.`)

            await registry.exit(listing, { from: accounts[0] })
            console.log('Applicant exits and requests to remove listing.')

            const isWhitelistedAfterExit = await registry.isWhitelisted(listing)
            assert.strictEqual(isWhitelistedAfterExit, false, 'the listing was not removed on exit')
            console.log('Listing is removed now.')

            const finalApplicantTokenHoldings = await token.balanceOf.call(accounts[0])
            console.log(`Final balance of Applicant after Exit is := ${finalApplicantTokenHoldings}`)

            // / market place check results
            // const market = await Market.deployed();
            const isListed1 = await market.checkListingStatus(listing, assetId, { from: accounts[0] })
            assert.strictEqual(isListed1, false, 'Listing should be removed')
            console.log('marketplace queries the voting result of listing')

            // let owner = await market.getInfo(assetId);
            // console.log(owner);

            // change internal flag for data asset
            await market.changeListingStatus(listing, assetId, { from: accounts[0] })
            // check status
            const isRemoved = await market.checkAsset(assetId, { from: accounts[0] })
            assert.strictEqual(isRemoved, false, 'assetId should be removed')
            console.log('marketplace has removed the listing')
        })
    })
})
