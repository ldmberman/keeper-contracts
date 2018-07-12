/* global artifacts, assert, contract, describe, it */
/* eslint-disable no-console, max-len */

const Market = artifacts.require('Market.sol')

const Web3 = require('web3')

const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'))

contract('Market', (accounts) => {
    describe('Test Unique Id', () => {
        // test RSA functions
        it('Should generate the same unique Id in Solidity and JS', async () => {
            const market = await Market.deployed()

            const str = 'data asset'
            console.log('input string : ', str)
            console.log('====== generate id from input string =======')
            const soid = await market.generateStr2Id(str, { from: accounts[0] })
            console.log('solidity: id from string : ', soid)

            const web3id = web3.sha3(str)
            console.log('web3: id from string : ', web3id)
            assert.strictEqual(soid, web3id, 'Two unique Id methods shall generate the same hash')

            console.log('====== generate id from input bytes =======')
            const byt = '0x7ace91f25e0838f9ed7ae259670bdf4156b3d82a76db72092f1baf06f31f5038'
            console.log('input bytes : ', byt)
            const soid2 = await market.generateBytes2Id(byt, { from: accounts[0] })
            console.log('solidity: id from bytes : ', soid2)

            const web3id2 = web3.sha3(byt, { encoding: 'hex' })
            console.log('web3: id from bytes : ', web3id2)
            assert.strictEqual(soid2, web3id2, 'Two unique Id methods shall generate the same hash')

            console.log('====== check duplicates Id =======')
            const assetId = '0x3b77b4ae630fb8898bef7db8107e2046ceb2c42e2b78d72d0da777e9d10bceb5'
            console.log('assetId : ', assetId)
            const valid = await market.checkUniqueId(assetId)
            console.log('assetId is unique now ')
            assert.strictEqual(valid, true, 'assetId shall be unique now')
            const assetPrice = 100
            await market.register(assetId, assetPrice, { from: accounts[0] })
            console.log('register with assetId now ')
            const valid2 = await market.checkUniqueId(assetId)
            console.log('assetId is duplicate now ')
            assert.strictEqual(valid2, false, 'assetId shall be duplicate now')

            console.log('====== check valid Id (registered) =======')
            // internally solidity will pad with 0 as '0x3b77b40000000000000000000000000000000000000000000000000000000000'
            const shortId = '0x3b77b4'
            console.log('input short assetId is : ', shortId)
            console.log('internally padded assetId : 0x3b77b40000000000000000000000000000000000000000000000000000000000')
            const short = await market.checkValidId(shortId, { from: accounts[0] })
            console.log('assetId is invalid')
            assert.strictEqual(short, false, 'assetId shall be invalid now')
            await market.register(shortId, assetPrice, { from: accounts[0] })
            console.log('register with assetId now ')
            const short2 = await market.checkValidId(shortId, { from: accounts[0] })
            console.log('assetId is valid now ')
            assert.strictEqual(short2, true, 'assetId shall be valid now')

            console.log('====== check longer Id =======')
            // internally solidity will truncate as '0x5b22b4ae630fb8898bef7db8103e2046ceb2d42e2b78d82d0da777e9d10bceb5'
            const longId = '0x5b22b4ae630fb8898bef7db8103e2046ceb2d42e2b78d82d0da777e9d10bceb53b77b4'
            console.log('input long assetId : ', longId)
            console.log('internally truncated assetId : 0x5b22b4ae630fb8898bef7db8103e2046ceb2d42e2b78d82d0da777e9d10bceb5')
        })
    })
})
