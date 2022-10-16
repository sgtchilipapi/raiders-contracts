require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");
require('dotenv').config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  paths: {
    artifacts: './src/artifacts',
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      chainId: 1337,
      allowUnlimitedContractSize: true
    },
    polygon: {
      url: "https://polygon-rpc.com/",
      accounts: [`0x${process.env.DEPLOYER_KEY}`]
    },
    mumbai: {
      url: "https://rpc.ankr.com/polygon_mumbai",
      accounts: [`0x${process.env.DEPLOYER_KEY}`]
    }
  },
  etherscan: {
    //For polygon mainnet and testnet
    apiKey: "TSEATXAVPD9QZZNA77KJ95T2Y6YGSUK1W4"
  },
  solidity: {
    compilers: [
      { version: "0.6.12" },
      { version: "0.8.17" }
    ]
  }
};
