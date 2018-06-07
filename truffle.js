


module.exports = {
  networks: {
    // config for solidity-coverage
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*", // Match any network id
      from: "0x7be721995c6ab3600ebb28d80a484826e9722b4a",
      gas: 6600000,
      //gasPrice: 250000,
    },
  },
};
