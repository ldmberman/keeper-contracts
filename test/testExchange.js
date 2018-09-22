const Token = artifacts.require('OceanToken.sol')
const Exchange = artifacts.require('OceanExchange.sol')
const Market = artifacts.require('OceanMarket.sol')
const Web3 = require('web3')

const web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'))

contract('OceanExchange', (accounts) => {
    describe('Test Ocean Exchange (Ether <> Ocean token)', () => {
        let token
        let market
        let exchange
        const scale = 10 ** 18

        beforeEach(async () => {
          token = await Token.deployed()
          market = await Market.deployed()
          exchange = await Exchange.deployed()
        })

        it('Should initialize exchange', async () => {
            await market.requestTokens(1000 * scale, { from: accounts[0] })
            const bal1 = await token.balanceOf.call(accounts[0])
            console.log(`User has ${bal1.toNumber() / scale} Ocean tokens now.`)

            await token.approve(exchange.address, 1000 * scale, { from: accounts[0] })

            // current exchange status
            let [ethPool, tokenPool, invariant, totalShare] = await exchange.exchangeStatus({ from: accounts[0] })
            console.log('initial status: ethPool=' + ethPool + ' tokenPool=' + tokenPool + ' invariant=' + invariant + ' totalShare=' + totalShare)

            // initialize exchange with ether and tokens
            await exchange.initializeExchange(100 * scale, { from: accounts[0],  value: web3.toWei(1, "ether")})
            let [ethPool1, tokenPool1, invariant1, totalShare1] = await exchange.exchangeStatus({ from: accounts[0] })
            console.log('status (Initialized): ethPool=' + ethPool1 / scale + ' tokenPool=' + tokenPool1 / scale + ' invariant=' + invariant1 / scale ** 2 + ' totalShare=' + totalShare1)
        })

        it('Should add liquidity', async () => {
            await exchange.addLiquidity(100 * scale, 99999999999999, { from: accounts[0],  value: web3.toWei(0.5, "ether")})
            let [ethPool, tokenPool, invariant, totalShare] = await exchange.exchangeStatus({ from: accounts[0] })
            console.log('status (liquidityAdded): ethPool=' + ethPool / scale + ' tokenPool=' + tokenPool / scale + ' invariant=' + invariant / scale ** 2 + ' totalShare=' + totalShare)
        })

        it('Should swap ether -> token ', async () => {
            console.log('buyer sends 1 ether into exchange')
            await exchange.ethToTokenSwap(10 * scale, 99999999999999, { from: accounts[1],  value: web3.toWei(1, "ether")})
            let [ethPool, tokenPool, invariant, totalShare] = await exchange.exchangeStatus({ from: accounts[1] })
            console.log('status (swap ether to token): ethPool=' + ethPool / scale + ' tokenPool=' + tokenPool / scale + ' invariant=' + invariant / scale ** 2 + ' totalShare=' + totalShare)

            const bal = await token.balanceOf.call(accounts[1])
            console.log(`buyer received ${bal.toNumber() / scale} Ocean tokens now.`)
            // approve
            await token.approve(exchange.address, bal * scale, { from: accounts[1] })
        })

        it('Should swap token -> ether', async () => {
          const ethbalB = web3.fromWei(web3.eth.getBalance(web3.eth.accounts[1]))
          console.log('seller sends 30 to exchange for ether; current ether balance = ', ethbalB.toNumber())
          await exchange.tokenToEthSwap(30 * scale, web3.toWei(0.01, "ether"), 99999999999999, { from: accounts[1]})
          let [ethPool, tokenPool, invariant, totalShare] = await exchange.exchangeStatus({ from: accounts[1] })
          console.log('status (swap token to ether): ethPool=' + ethPool / scale + ' tokenPool=' + tokenPool / scale + ' invariant=' + invariant / scale ** 2 + ' totalShare=' + totalShare)

          const bal = await token.balanceOf.call(accounts[1])
          const ethbal = web3.fromWei(web3.eth.getBalance(web3.eth.accounts[1]))
          console.log(`buyer has ${ethbal.toNumber()} ether and ${bal.toNumber() / scale} Ocean tokens available now.`)

        })

        it('Should remove liquidity', async () => {
          await exchange.removeLiquidity(300, web3.toWei(0.001, "ether"), 1 * scale, 99999999999999, { from: accounts[0]})
          let [ethPool, tokenPool, invariant, totalShare] = await exchange.exchangeStatus({ from: accounts[0] })
          console.log('status (liquidity removed): ethPool=' + ethPool / scale + ' tokenPool=' + tokenPool / scale + ' invariant=' + invariant / scale ** 2 + ' totalShare=' + totalShare)

          const bal = await token.balanceOf.call(accounts[0])
          const ethbal = web3.fromWei(web3.eth.getBalance(web3.eth.accounts[0]))
          console.log(`user has ${ethbal.toNumber()} ether and ${bal.toNumber() / scale} Ocean tokens available now.`)
        })
    })
})
