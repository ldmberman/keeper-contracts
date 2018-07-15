/* global artifacts, assert, contract, describe, it */
/* eslint-disable no-console, max-len */

const Token = artifacts.require('OceanToken.sol')
const Market = artifacts.require('Market.sol')
const ACL = artifacts.require('ACL.sol')

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

            // 2. consumer create an order
            const ordername = 'first order'
            const orderId = await acl.generateOrderId(ordername, { from: accounts[1] })
            await acl.createOrder(resourceId, orderId, accounts[0], { from: accounts[1] })
            console.log('consumer creates an order with id : ', orderId)

            // 3. provider confirms the order
            await acl.providerConfirm(orderId, { from: accounts[0] })
            console.log('provider has confirmed the order')

            // 4. consumer pay the order
            const bal1 = await token.balanceOf.call(market.address)
            console.log(`market has balance := ${bal1.valueOf()} before payment`)
            await acl.payOrder(orderId, { from: accounts[1] })
            const bal2 = await token.balanceOf.call(market.address)
            console.log(`market has balance := ${bal2.valueOf()} after payment`)
            console.log('consumer has paid the order')

            // 5. consumer generate Temp Public key
            const modulusBit = 512
            const key = ursa.generatePrivateKey(modulusBit, 65537)
            const privatePem = ursa.createPrivateKey(key.toPrivatePem())
            const publicPem = ursa.createPublicKey(key.toPublicPem())
            // convert public key into string so that to store on-chain
            const publicKey = publicPem.toPublicPem('utf8')
            console.log('public key is: = ', publicKey)

            // consumer add temp public key
            await acl.addTempPubKey(orderId, publicKey, { from: accounts[1] })
            console.log('consumer has added the temp public key')

            // 6. provider query the temp public key string from on-chain order
            const OnChainPubKey = await acl.queryTempKey(orderId, { from: accounts[0] })
            console.log('provider has retrieved the temp public key')
            assert.strictEqual(publicKey, OnChainPubKey, 'two public keys should match.')

            // 7. provider encrypt the JWT token
            // provider convert the retrieved public key string into Public Key
            const getPubKeyPem = ursa.coerceKey(OnChainPubKey)
            // encrypt the JWT token using public key
            const encJWT = getPubKeyPem.encrypt('eyJhbGciOiJIUzI1', 'utf8', 'base64')
            // const encJWT = publicPem.encrypt('eyJhbGciOiJIUzI1', 'utf8', 'base64')
            await acl.addToken(orderId, encJWT, { from: accounts[0] })
            console.log('provider has commited the encrypted JWT token :', encJWT.toString())

            // 8. consumer retrieve and decrypt the JWT token
            const onChainencToken = await acl.queryToken(orderId, { from: accounts[1] })
            const decryptJWT = privatePem.decrypt(onChainencToken, 'base64', 'utf8')
            console.log('consumer decrypts JWT token :', decryptJWT.toString())

            // 9. consumer confirms the delivery
            await acl.confirmDelivery(orderId, { from: accounts[1] })
            console.log('consumer confirmed the delivery of this order')

            const pbal = await token.balanceOf.call(accounts[0])
            console.log(`provider has balance := ${pbal.valueOf()} now`)

            const mbal = await token.balanceOf.call(market.address)
            console.log(`market has balance := ${mbal.valueOf()} now`)
        })
    })
})
