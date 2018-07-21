/* global artifacts, assert, contract, describe, it */
/* eslint-disable no-console, max-len */

const Token = artifacts.require('OceanToken.sol')
const Market = artifacts.require('Market.sol')
const ACL = artifacts.require('Auth.sol')

const ursa = require('ursa')

contract('ACL', (accounts) => {
    describe('Test On-chain Authorization', () => {
        // support upto 50 assets and providers; each asset has one single provider at this time
        it('Should walk through Authorization Process', async () => {
            // const marketPlace = await Market.deployed();
            const token = await Token.deployed()
            const market = await Market.deployed()
            const acl = await ACL.deployed()

            const str = 'resource'
            const resourceId = await market.generateStr2Id(str, { from: accounts[0] })
            const resourcePrice = 100
            // 1. provider register dataset
            await market.register(resourceId, resourcePrice, { from: accounts[0] })
            console.log('publisher registers asset with id = ', resourceId)

            // consumer accounts[1] request initial funds to play
            await market.requestTokens(2000, { from: accounts[1] })
            const bal = await token.balanceOf.call(accounts[1])
            console.log(`consumer has balance := ${bal.valueOf()} now`)
            // consumer approve market to withdraw amount of token from his account
            await token.approve(market.address, 200, { from: accounts[1] })

            // 2. consumer initiate an access request
            const modulusBit = 512
            const key = ursa.generatePrivateKey(modulusBit, 65537)
            const privatePem = ursa.createPrivateKey(key.toPrivatePem())
            const publicPem = ursa.createPublicKey(key.toPublicPem())
            // convert public key into string so that to store on-chain
            const publicKey = publicPem.toPublicPem('utf8')
            console.log('public key is: = ', publicKey)

            // generate access request unique Id
            const accessId = await acl.generateRequestId(resourceId, accounts[0], publicKey, { from: accounts[1] })
            // create the access request
            await acl.initiateAccessRequest(accessId, resourceId, accounts[0], publicKey, 9999999999, { from: accounts[1] })
            console.log('consumer creates an request with id : ', resourceId)

            // 3. provider commit the request
            const JWThash = await market.generateStr2Id('eyJhbGciOiJIUzI1', { from: accounts[0] })
            await acl.commitAccessRequest(accessId, true, 9999999999, 'discovery', 'read', 'slaLink', 'slaType', JWThash)
            console.log('provider has committed the order')

            // 4. consumer make payment
            const bal1 = await token.balanceOf.call(market.address)
            console.log(`market has balance := ${bal1.valueOf()} before payment`)
            await market.sendPayment(accessId, accounts[0], 100,  9999999999, { from: accounts[1] })
            const bal2 = await token.balanceOf.call(market.address)
            console.log(`market has balance := ${bal2.valueOf()} after payment`)
            console.log('consumer has paid the order')

            // 5. provider delivery the encrypted JWT token
            const OnChainPubKey = await acl.getTempPubKey(accessId, { from: accounts[0] })
            //console.log('provider Retrieve the temp public key:', OnChainPubKey)
            assert.strictEqual(publicKey, OnChainPubKey, 'two public keys should match.')

            const getPubKeyPem = ursa.coerceKey(OnChainPubKey)
            const encJWT = getPubKeyPem.encrypt('eyJhbGciOiJIUzI1', 'utf8', 'base64')
            await acl.deliverAccessToken(accessId, encJWT, { from: accounts[0] })
            console.log('provider has delivered the encrypted JWT')

            // 4. consumer download the encrypted token and decrypt
            const onChainencToken = await acl.getEncJWT(accessId, { from: accounts[1] })
            const decryptJWT = privatePem.decrypt(onChainencToken, 'base64', 'utf8')
            console.log('consumer decrypts JWT token :', decryptJWT.toString())
            assert.strictEqual(decryptJWT.toString(), 'eyJhbGciOiJIUzI1', 'two public keys should match.')

            // 6. provider verify the JWT is delivered to consumer
            const proofJWTHash = await market.generateStr2Id(decryptJWT.toString(), { from: accounts[0] })
            await acl.verifyAccessTokenDelivery(accessId, proofJWTHash, { from: accounts[0] })
            console.log('provider verify the delivery and request payment')

            // check balance
            const pbal = await token.balanceOf.call(accounts[0])
            console.log(`provider has balance := ${pbal.valueOf()} now`)

            const mbal = await token.balanceOf.call(market.address)
            console.log(`market has balance := ${mbal.valueOf()} now`)
        })
    })
})
