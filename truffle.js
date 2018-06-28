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
            from: "0x00bd138abd70e2f00903268f3db08f2d25677c9e"
        },
        ocean_poa_net: {
            host: '40.115.16.244',
            port: 8545,
            network_id: '*',
            gas: 6000000,
            from: "0x00bd138abd70e2f00903268f3db08f2d25677c9e"
        },
    },
    solc: {
        optimizer: {
            enabled: true,
            runs: 200
        },
    },
}
