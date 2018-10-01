/* global artifacts, assert, contract, describe, it */
/* eslint-disable no-console, max-len */

const Fitchain = artifacts.require('Fitchain.sol')
const ethers = require('ethers')
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

            // proof of training delivered and signed by the fitchain validator set
            const PoTMessage = "FinalTransactionEndofTrainingEoT"
            const IPFSResult = "0x06b0a4f426f6713234b2d4b2468640bc4e0bb72657a920ad24c5087153c593c8"

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
            assert.strictEqual(modelStatus, false, "Model Status should return false")

            // model result should return 0 IPFS hash
            const modelResult = await fitchain.getResult(condition)
            assert.strictEqual(modelResult, '0x0000000000000000000000000000000000000000000000000000000000000000',
                               " model result should return 0 IPFS hash")


             // validators sign the PoT message (EoT)
            const prefix = '0x'
            const hexString = Buffer.from(PoTMessage).toString('hex')
            console.log(`${prefix}${hexString}`)
            const signature = web3.eth.sign(accounts[1], `${prefix}${hexString}`)
            console.log('consumer signature: ', signature)

            const sig = ethers.utils.splitSignature(signature)

            const EthereumPoTMessage = `\x19Ethereum Signed Message:\n${PoTMessage.length}${PoTMessage}`
            const EthereumPoTMessageHash = web3.sha3(EthereumPoTMessage)
            console.log('signed message from consumer to be validated: ', EthereumPoTMessage)

            const res = await fitchain.verifySignature(accounts[1], EthereumPoTMessageHash, sig.v, sig.r, sig.s, { from: accounts[0] })
            console.log('validate the signature comes from consumer: ', res)

            // catenating the signatures into one piece (Final Proof)
            //const signatures = signature1+signature2

            //console.log(condition, PoTMessage , signatures, [validator1, validator2], IPFSResult)
            //await fitchain.getProof(condition, PoTMessage , signatures, [validator1, validator2], IPFSResult, { from: accounts[0] })


        })

    })


})
// "0xf5503b3b30fffd15207e7bd566d9eb873944deef45e33494d388b2dd921e7550","0x9c4e477188259ef2c9f7953526cc868a7b1cd66e", "0xe49e38a62c96a10033029fde293c82d87de8515c2bc02283f8413a7ca509b2ac4db20995885650b226766f9934860d5445445a24fd81cfa8984517aa3f81b75400", 0
