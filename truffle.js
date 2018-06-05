
module.exports = {
  networks: {
    // config for solidity-coverage
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*", // Match any network id
      from: "0xdeb29444fc766e05a59859774af99b9ab89d1ff7",
      gas: 6600000,
      //gasPrice: 250000,
    },
  },
};
