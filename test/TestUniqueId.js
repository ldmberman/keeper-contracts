/* global artifacts, assert, contract, describe, it */
/* eslint-disable no-console, max-len */

const Market = artifacts.require('Market.sol')
var Web3 = require("web3");
var web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

contract('Market', (accounts) => {
    describe('Test Unique Id', () => {
        // test RSA functions
        it('Should generate the same unique Id in Solidity and JS', async () => {
            const market = await Market.deployed()

            const str = 'data asset'
            console.log('input string : ', str)
            console.log('====== generate id from input string =======')
            soid = await market.generateStr2Id(str)
            console.log('solidity: id from string : ', soid)

            web3id = web3.sha3(str)
            console.log('web3: id from string : ', web3id)
            assert.strictEqual(soid, web3id, 'Two unique Id methods shall generate the same hash')

            console.log('====== generate id from input bytes =======')
            const byt = '0x7ace91f25e0838f9ed7ae259670bdf4156b3d82a76db72092f1baf06f31f5038'
            console.log('input bytes : ', byt)
            soid2 = await market.generateBytes2Id(byt)
            console.log('solidity: id from bytes : ', soid2)

            web3id2 = web3.sha3(byt, {encoding: 'hex'})
            console.log('web3: id from bytes : ', web3id2)
            assert.strictEqual(soid2, web3id2, 'Two unique Id methods shall generate the same hash')
        })
    })
})
