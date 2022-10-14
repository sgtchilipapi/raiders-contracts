// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers } = require("hardhat");
const hre = require("hardhat");
require('dotenv').config()

async function main() {
  const clank = await deployERC20("ClankToken")
  const boom = await deployERC20("BoomSteel")
  const thump = await deployERC20("ThumpIron")
  const clink = await deployERC20("ClinkGlass")
  const snap = await deployERC20("SnapLink")
  const black = await deployERC20("BlackSparkstone")
  const white = await deployERC20("WhiteSparkstone")
  const red = await deployERC20("RedSparkstone")
  const blue = await deployERC20("BlueSparkstone")
  const _chef = await deployChef(clank)
  

  async function deployERC20(ContractName){
    const ERC20Token = await ethers.getContractFactory(ContractName)
    const token = await ERC20Token.deploy()
    await token.deployed()
    console.log(`${ContractName} token deployed at: ${token.address}`)
    return token.address
  }

  async function deployChef(tokenAddress){
    const Chef = await ethers.getContractFactory("MiniChefV2")
    const chef = await Chef.deploy(tokenAddress)
    await chef.deployed()
    console.log(`MiniChefV2 Fork deployed at: ${chef.address}`)
    return chef.address
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
