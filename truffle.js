


module.exports = {
  networks: {
    // config for solidity-coverage
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*", // Match any network id
      from: "0xeaf1a43c6b1dde8bdcafdf829d7b31f4e9c54290",
      gas: 6600000,
      //gasPrice: 250000,
    },
  },
};
