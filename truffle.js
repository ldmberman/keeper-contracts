
module.exports = {
  networks: {
    // config for solidity-coverage
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*", // Match any network id
      from: "0x2b9bab61a2606a587c7e5d355b5a8c100eaa01a3",
      gas: 6600000,
      //gasPrice: 250000,
    },
  },
};
