


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
    ocean: {
      host: "104.214.229.114",
      port: 8545,
      network_id: "*", // Match any network id
      //from: "0x00bd138abd70e2f00903268f3db08f2d25677c9e",
      //gas: 6600000,
      //gasPrice: 250000,
    },
    kovan: {
      provider: new HDWalletProvider(mnemonic, "https://kovan.infura.io/Kuo1lxDBsFtMnaw6GiN2"),
      network_id: 42,
      gas: 4500000,
      gasPrice: 25000000000,
    },
  },
};
