const HDWalletProvider = require('truffle-hdwallet-provider')

// etherbase of that nmemoric: 0x372481Ab4BaB2e06b6737760C756bB238E9024a4
const nmemoric = 'inform across tag random picture urban true effort practice wool attitude web'

module.exports = {
    networks: {
        // config for solidity-coverage
        development: {
            host: 'localhost',
            port: 8545,
            network_id: '*',
            gas: 6000000,
        },
        ocean_poa_net_local: {
            host: 'localhost',
            port: 8545,
            network_id: '*',
            gas: 6000000,
            from: '0x00bd138abd70e2f00903268f3db08f2d25677c9e'
        },
        ocean_poa_net: {
            host: '40.115.16.244',
            port: 8545,
            network_id: '*',
            gas: 6000000,
            from: '0x00bd138abd70e2f00903268f3db08f2d25677c9e'
        },
        kovan: {
            provider: () => new HDWalletProvider(nmemoric, `https://kovan.infura.io/v3/${process.env.INFURA_TOKEN}`),
            network_id: '42'
        }
    },
    solc: {
        optimizer: {
            enabled: true,
            runs: 200
        },
    },
}
