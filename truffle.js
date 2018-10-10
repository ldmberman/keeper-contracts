const HDWalletProvider = require('truffle-hdwallet-provider')

// etherbase of that nmemoric: 0x2c0d5f47374b130ee398f4c34dbe8168824a8616
const nmemoric = process.env.KOVAN_NMEMORIC

module.exports = {
    networks: {
        development: {
            host: 'localhost',
            port: 8545,
            network_id: '*',
            gas: 6000000
        },
        ocean_poa_net_local: {
            host: process.env.POA_HOST,
            port: 8545,
            network_id: '*',
            gas: 4500000,
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
            provider: () => new HDWalletProvider(nmemoric, `https://kovan.infura.io/v2/${process.env.INFURA_TOKEN}`),
            network_id: '42'
        }
    },
    compilers: {
        solc: {
            version: '0.4.25'
        }
    },
    solc: {
        optimizer: {
            enabled: true,
            runs: 200
        }
    }
}
