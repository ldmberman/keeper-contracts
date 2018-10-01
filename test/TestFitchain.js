/* global artifacts, assert, contract, describe, it */
/* eslint-disable no-console, max-len */

const Fitchain = artifacts.require('Fitchain.sol')
const Web3 = require('web3')
const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'))


contract('Fitchain', (accounts) => {
    describe('Test Fitchain Driver', () => {

        it('should be able to invoke and verify PoT in Fitchain', async () => {

            const fitchain = await Fitchain.deployed()

            const consumer = accounts[2]
            const mlProvider = accounts[3]
            const dataProvider = accounts[4]

            const service   = "0x2e0a37a59681024a585429275505ce217e6249e85e1b2af34c3edf177a70193b"
            const condition = "0xc8cd645f78d8350c3e44b289c7f0010ec8de2dfa0f1003e582709253ad1568c4"
            const dataAsset = "0xc1964de7782bca50b19ae7f8aad600816718485d3926ca4f0dcdd885115e4fe8"
            const mlAsset   = "0xff92c5d23ed2b8e4af5b2bb496b33df4836cd0c1af15cc8f41c8488301d9c1b9"

            // fitchain PoT validator set
            const validators = 2
            const validator1 = accounts[5]
            const validator2 = accounts[6]

            // invoke fitchain PoT
            // this request will be delivered to Fitchain Network through Ocean Relay
            await fitchain.invoke(condition,
                    validators,
                    service,
                    consumer,
                    mlProvider,
                    dataProvider,
                    mlAsset,
                    dataAsset, { from: consumer })
            // catch the the network event
            const invokeFitchainPoT = fitchain.InvokeFitchainPoT()
            invokeFitchainPoT.watch((error, result) => {
                if (!error) {
                    assert.strictEqual(result.args.modelId, condition, 'ModelId and Condition should match')
                    assert.strictEqual(result.args.consumer, consumer, "Consumer addresses should match")
                    assert.strictEqual(result.args.mlProvider, mlProvider, "mlProvider addresses should match")
                    assert.strictEqual(result.args.dataProvider, dataProvider, "dataProvider addresses should match")
                    assert.strictEqual(result.args.mlAsset, mlAsset, "mlAsset Ids should match")
                    assert.strictEqual(result.args.dataAsset, dataAsset, "dataAsset Ids should match")
                }else{
                    console.log(error)
                }
            })

            // get status of the model
            const modelStatus = await fitchain.getStatus(condition)
            //console.log(modelStatus)
            assert.strictEqual(modelStatus, false, "Model Status should return false")

        })

    })


})
