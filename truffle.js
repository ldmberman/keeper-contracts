module.exports = {
    networks: {
    // config for solidity-coverage
        development: {
            host: 'localhost',
            port: 8545,
            network_id: '*',
            gas: 6000000
        },
    },
    solc: {
        optimizer: {
            enabled: true,
            runs: 200
        },
    },
}
