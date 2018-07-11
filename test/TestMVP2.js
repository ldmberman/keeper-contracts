/* global artifacts, assert, contract, describe, it */
/* eslint-disable no-console, max-len */

const Token = artifacts.require('OceanToken.sol')
const Market = artifacts.require('Market.sol')

const ursa = require('ursa')

contract('Market', (accounts) => {
    describe('Test MVP-2 use stories', () => {
        // test RSA functions
        it('Should encrypt and decrypt using RSA', async () => {
            const modulusBit = 512
            const key = ursa.generatePrivateKey(modulusBit, 65537)

            const privatePem = ursa.createPrivateKey(key.toPrivatePem())
            const privateKey = privatePem.toPrivatePem('utf8')

            const publicPem = ursa.createPublicKey(key.toPublicPem())
            const publicKey = publicPem.toPublicPem('utf8')
            console.log(privateKey.toString('ascii'))
            console.log(publicKey.toString('ascii'))

            const msg = 'http://aws.amazon.com'
            console.log('original message : ', msg)
            const enc = publicPem.encrypt(msg, 'utf8', 'base64')
            console.log('encrypted with public key : ', enc.toString())

            const plaintext = privatePem.decrypt(enc, 'base64', 'utf8')
            console.log('decrypted with private key : ', plaintext.toString())
        })
        // support upto 50 assets and providers; each asset has one single provider at this time
        it('Should walk through MVP-2 user story', async () => {
            // const marketPlace = await Market.deployed();
            const token = await Token.deployed()
            const market = await Market.deployed()


            const assetId = 1
            const assetPrice = 100
            // 1. register dataset
            await market.register(assetId, assetPrice, { from: accounts[0] })
            console.log('publisher registers asset with id = ", assetId, " and price = ', assetPrice)

            // 2. publisher register the Asset metadata in Ocean DB (BDB) using the assetId as key
            console.log('*publisher shall register asset metadata in Ocean DB (BDB)')

            // 3. Consumer is subscribed to all the new assets registered


            // 4. Consumer ask to Ocean DB about the Metadata of a list of Assets
            console.log('*consumer ask Ocean DB about the metadata of a list of assets')

            // 5. Consumer execute the keeper::purchase function for an specific asset
            const orderId = 1
            // 5.1 request tokens for purchase
            await market.requestTokens(2000, { from: accounts[1] })
            console.log('consumer requests 2000 ocean tokens for purchase')
            // 5.2 approve the amount of tokens for this purchase
            await token.approve(market.address, assetPrice, { from: accounts[1] })
            // 5.3 make the payment for purchase
            await market.purchase(assetId, orderId, { from: accounts[1] })
            console.log('consumer pay 100 ocean tokens to purchase')
            //  6. Publisher would be able to retrieve the assetId and the Consumer public key
            const modulusBit = 512
            const key = ursa.generatePrivateKey(modulusBit, 65537)

            const privatePem = ursa.createPrivateKey(key.toPrivatePem())
            // privateKey = privatePem.toPrivatePem('utf8')

            const publicPem = ursa.createPublicKey(key.toPublicPem())
            // publicKey = publicPem.toPublicPem('utf8')


            // 7. Publisher encrypt the consumption information (url + token) using the Consumer public key
            const encUrl = publicPem.encrypt('http://aws.amazon.com', 'utf8', 'base64')
            console.log('publisher encrypt url with consumer public key : ')
            console.log(encUrl)
            const encToken = publicPem.encrypt('aXsTSt', 'utf8', 'base64')
            console.log('publisher encrypt token with consumer public key : ')
            console.log(encToken)

            // 8. Publisher publish the consumption information encrypted using the keeper::publish function
            // convert string into bytes32 implicitly
            await market.publish(assetId, orderId, encUrl, encToken, { from: accounts[0] })
            console.log('publisher publish the encrypted url and token on-chain')

            // 9. Consumer receive an event AssetPublished notifying to him the consumption information is encrypted and available on-chain

            // 10. Consumer decrypt the consumption information
            const onChainencUrl = await market.getEncUrl(orderId, { from: accounts[1] })
            const onChainencToken = await market.getEncToken(orderId, { from: accounts[1] })
            console.log('consumer retrieve the encrypted access info from on-chain')

            const decryptUrl = privatePem.decrypt(onChainencUrl, 'base64', 'utf8')
            console.log('consumer decrypt url with private key := ', decryptUrl)
            const decryptToken = privatePem.decrypt(onChainencToken, 'base64', 'utf8')
            console.log('consumer decrypt token with private key := ', decryptToken)

            // 11. Consumer query to the Provider to download the asset (sending also the decrypted url+token)
            console.log('*consumer query the provider to download asset using accessing token')

            // provider set himself as the provider of this order
            await market.setOrderProvider(orderId, { from: accounts[0] })
            console.log('provider verify order is paid and set himself as the provider of this order')

            // user confirms the delivery
            await market.confirmDelivery(orderId, { from: accounts[1] })
            console.log('provider serves the download request and consumer confirms delivery')

            // provider can request payment
            await market.requestPayment(orderId, { from: accounts[0] })
            const bal1 = await token.balanceOf.call(accounts[0])
            console.log(`provider has balance := ${bal1.valueOf()}`)

            const bal2 = await token.balanceOf.call(accounts[1])
            console.log(`consumer has balance := ${bal2.valueOf()}`)
        })
    })
})
