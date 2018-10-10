/* eslint-env mocha */
/* eslint-disable no-console */
/* global artifacts, assert, contract, describe, it */

const DIDRegistry = artifacts.require('DIDRegistry.sol')

const Web3 = require('web3')
const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'))

const utils = require('./utils.js')

contract('DIDRegistry', (accounts) => {
    describe('Register decentralised identifiers with attributes, fetch attributes by DID', () => {
        it('Should discover the attribute after registering it', async () => {
            const did = 'did:ocn:test-register-attribute'
            const registry = await DIDRegistry.new(did, 0) // Asset

            const host = 'http://example.com'
            const provider = web3.utils.fromAscii('provider')
            const result = await registry.registerAttribute(provider, host)

            utils.assertEmitted(result, 1, 'DIDAttributeRegistered')

            const payload = result.logs[0].args
            assert.strictEqual(did, payload.did)
            assert.strictEqual(accounts[0], payload.owner)
            assert.strictEqual(0, web3.utils.toDecimal(payload._type))
            assert.strictEqual('provider', web3.utils.hexToString(payload.key))
            assert.strictEqual(host, payload.value)
        })

        it('Should not fail to register the same attribute twice', async () => {
            const did = 'did:ocn:test-register-same-attribute-twice'
            const registry = await DIDRegistry.new(did, 0) // Asset

            const host = 'http://example.com'
            const provider = web3.utils.fromAscii('provider')
            await registry.registerAttribute(provider, host)
            // try to register the same attribute the second time
            const result = await registry.registerAttribute(provider, host)

            utils.assertEmitted(result, 1, 'DIDAttributeRegistered')
        })

        it('Should register multiple attributes', async () => {
            const did = 'did:ocn:test-register-multiple-attributes'
            const registry = await DIDRegistry.new(did, 0) // Asset

            const host = 'http://example.com'
            const provider = web3.utils.fromAscii('provider')
            await registry.registerAttribute(provider, host)

            const alternativeProvider = web3.utils.fromAscii('alternative-provider')
            const result = await registry.registerAttribute(alternativeProvider, host)

            utils.assertEmitted(result, 1, 'DIDAttributeRegistered')

            const payload = result.logs[0].args
            assert.strictEqual(did, payload.did)
            assert.strictEqual(accounts[0], payload.owner)
            assert.strictEqual(0, web3.utils.toDecimal(payload._type))
            assert.strictEqual('alternative-provider', web3.utils.hexToString(payload.key))
            assert.strictEqual(host, payload.value)
        })

        it('Should only allow the owner to set an attribute', async () => {
            const did = 'did:ocn:test-register-multiple-attributes'
            const registry = await DIDRegistry.new(did, 0) // Asset

            const host = 'http://example.com'
            const provider = web3.utils.fromAscii('provider')

            var failed = false
            try {
                const badSender = { from: accounts[1] }
                await registry.registerAttribute(provider, host, badSender)
            } catch (e) {
                failed = true
            }
            assert.equal(true, failed)
        })
    })
})
