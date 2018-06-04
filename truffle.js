
module.exports = {
  networks: {
    // config for solidity-coverage
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*", // Match any network id
      from: "0x87656e3b552b16986fa57427972880efeec10253",
      gas: 6000000,
      //gasPrice: 25000000000,
    },
  },
};
