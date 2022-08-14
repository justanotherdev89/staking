const HDWalletProvider = require("truffle-hdwallet-provider-klaytn");

module.exports = {
  networks: {
    baobab: {
      provider: () => { return new HDWalletProvider("0xe63b5c0011598ec552b3e8cd03077b63a4c7b9a3ba96ac61527bdfd0a89bb832", "https://api.baobab.klaytn.net:8651") },
      network_id: '1001', //Klaytn baobab testnet's network id
      gas: 20000000,
      gasPrice: 75000000000,
    },
    development: {
      host: "localhost",
      port: 7545,
      network_id: "5777"
    }
    // development: {
    //   provider: () => { return new HDWalletProvider("0xe63b5c0011598ec552b3e8cd03077b63a4c7b9a3ba96ac61527bdfd0a89bb832", "https://api.baobab.klaytn.net:8651") },
    //   network_id: '1001', //Klaytn baobab testnet's network id
    //   gas: '8500000',
    //   gasPrice: null
    // }
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    // timeout: 100000
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.15"    // Specify compiler's version to 0.5.6
    }
  }
}