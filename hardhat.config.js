require("@nomicfoundation/hardhat-toolbox");
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
  solidity: {
    compilers: [
      { version: "0.6.12" },
      { version: "0.8.17" }
    ]
  }
};
