/* global artifacts, assert, contract, describe, it */
/* eslint-disable no-console, max-len */

const DIDRegistry = artifacts.require('DIDRegistry.sol')
const Web3 = require('web3')
const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'))

contract('DIDRegistry', (accounts) => {
    describe('Test DID Registry on-chain', () => {
        it('Should be able to register DID record', async () => {
            const registry = await DIDRegistry.deployed()

            console.log("\t >> Register new DID Record")
            await registry.registerDID("did:ocn:21tDAKCERh95uGgKbJNHYp",
                                                      "https://myprovider.example.com",
                                                      { from: accounts[1] }
                                                      )
            const didRegistered = registry.DIDRegistered({fromBlock: 0,toBlock: 'latest'})
            didRegistered.watch((error, result) => {
                if (!error) {
                    console.log(result.args);
                }
            })

            console.log("\t >> Update DID Registry")
            await registry.updateDIDReference("did:ocn:21tDAKCERh95uGgKbJNHYp",{ from: accounts[1] })
            const didUpdated = registry.DIDUpdated({}, {fromBlock: 0,toBlock: 'latest'})
            didUpdated.watch((error, result) => {
                if (!error) {
                    console.log(result.args)
                }
            })


            console.log("\t >> Update unregistered did")
            const urlUpdated = registry.DIDUpdated({fromBlock: 0,toBlock: 'latest'})
            await registry.updateUrlReference("https://myprovider.example.com",{ from: accounts[4] })
            urlUpdated.watch((error, result) => {
                if (!error) {
                    console.log(result.args)
                }
            })

            const notExist = registry.NotExist({fromBlock: 0,toBlock: 'latest'})
            notExist.watch((error, result) => {
                if (!error) {
                    console.log(result.args)
                }
            })
        })
    })
})
