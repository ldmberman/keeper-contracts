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
            const state = await registry.registerDID("did:ocn:21tDAKCERh95uGgKbJNHYp",
                                                      "https://myprovider.example.com",
                                                      { from: accounts[1] }
                                                      )
            console.log(state)
            const didRegistered = registry.DIDRegistered({fromBlock: 0,toBlock: 'latest'})
            console.log(didRegistered)
            didRegistered.watch((error, result) => {
                if (!error) {
                    console.log(result.args);
                }
            })

            console.log("\t >> Update DID Registry")
            const state2 = await registry.updateDIDReference("did:ocn:21tDAKCERh95uGgKbJNHYp",{ from: accounts[1] })
            const didUpdated = registry.DIDUpdated({}, {fromBlock: 0,toBlock: 'latest'})
            didUpdated.watch((error, result) => {
                if (!error) {
                    console.log(result.args)
                }
            })

            console.log(state2)
            console.log("\t >> Update did for unregistered actor")
            const urlUpdated = registry.DIDUpdated({fromBlock: 0,toBlock: 'latest'})
            const UpdateState = await registry.updateUrlReference("https://myprovider.example.com",{ from: accounts[4] })
            console.log(UpdateState)
            urlUpdated.watch((error, result) => {
                if (!error) {
                    console.log(result.args)
                }
            })
            console.log(UpdateState)
            console.log("Not Exist record!")
            const notExist = registry.NotExist({fromBlock: 0,toBlock: 'latest'})
            notExist.watch((error, result) => {
                if (!error) {
                    console.log(result.args)
                }
            })
            console.log(notExist)
            console.log("Delete DID from Registry")
            const deleteState = await registry.unregisterDID({ from: accounts[4]})
            console.log(deleteState);
//            console.log("\t >> Repeat DID Registry for the same actor")
//            await registry.registerDID("did:ocn:21tDAKCERh95uGgKbJNHYp",
//                                                      "https://myprovider.example.com",
//                                                      { from: accounts[1] }
//                                                      )
        })
    })
})
