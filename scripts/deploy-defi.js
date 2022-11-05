// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers } = require("hardhat");
const hre = require("hardhat");
const { checkCustomRoutes } = require("next/dist/lib/load-custom-routes");
require('dotenv').config()
const deployments = require("../app-config/deployments")

async function main() {
  const clank = await deployERC20("ClankToken")
  const boom = await deployERC20("BoomSteel")
  const thump = await deployERC20("ThumpIron")
  const clink = await deployERC20("ClinkGlass")
  const snap = await deployERC20("SnapLink")
  const yellow = await deployERC20("YellowSparkstone")
  const white = await deployERC20("WhiteSparkstone")
  const red = await deployERC20("RedSparkstone")
  const blue = await deployERC20("BlueSparkstone")
  const enerlink = await deployERC20("EnerLink")
  await setPairAddress(clank, [boom, thump, clink, snap], [yellow, white, red, blue])
  const mainPair = await getClankWmaticPair(clank)
  const _chef = await deployChef(clank.address, mainPair)

  async function deployERC20(ContractName){
    const ERC20Token = await ethers.getContractFactory(ContractName)
    const token = await ERC20Token.deploy()
    await token.deployed()
    console.log(`${ContractName} token deployed at: ${token.address}`)
    return token
  }

  async function deployChef(tokenAddress, lpAddress){
    const Chef = await ethers.getContractFactory("MiniChefV2")
    const chef = await Chef.deploy(tokenAddress)
    await chef.deployed()
    console.log(`MiniChefV2 Fork deployed at: ${chef.address}`)

    ///Add CLANK-WMATIC pair in MiniChefV2
    const addPoolTx = await chef.add(1000, lpAddress, "0x0000000000000000000000000000000000000000")
    await addPoolTx.wait()
    console.log(`Pool CLANK-WMATIC added in MiniChefV2!`)

    ///Set emission rate of CLANK per second
    const emissionRate = ethers.utils.parseEther("0.01")
    const setEmissionRateTx = await chef.setSushiPerSecond(emissionRate)
    await setEmissionRateTx.wait()
    console.log(`Emission rate set at ${emissionRate} per second`)

    return chef
  }

  async function setPairAddress(clank, materials, catalysts){
    const Factory = await ethers.getContractFactory("UniswapV2Factory")
    const factory = Factory.attach(deployments.contracts.defi.factory.address)
    for(let i = 0; i < 4; i++){
      const createPair = await factory.createPair(clank.address, materials[i].address)
      await createPair.wait()
      const pairAddress = await factory.getPair(clank.address, materials[i].address)
      const setPairInToken = await catalysts[i].setLpToken(pairAddress)
      await setPairInToken.wait()
      console.log(`LP: ${pairAddress} set in catalyst ${i}`)
    }
  }

  async function getClankWmaticPair(clank){
    const Factory = await ethers.getContractFactory("UniswapV2Factory")
    const factory = Factory.attach(deployments.contracts.defi.factory.address)
    const createPair = await factory.createPair(clank.address, deployments.contracts.tokens.wmatic.address)
    await createPair.wait()
    const pairAddress = await factory.getPair(clank.address, deployments.contracts.tokens.wmatic.address)
    console.log(`LP CLANK-wMATIC pair set with address: ${pairAddress}`)
    return pairAddress
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
