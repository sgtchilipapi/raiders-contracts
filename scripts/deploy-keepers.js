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
    ///For MATIC mainnet
    ///const mainnetVRF = await deploySubscriptionVRF("VRFv2Consumer", 0, "0xAE975071Be8F8eE67addBC1A82488F1C24858067", "0xcc294a196eeeb44da2888d17c0625cc88d70d9760a69d58d853ba6581a9ab0cd")

    ///For mumbai testnet
    const keeper = await deploySubscriptionKeeper("DungeonKeeper", "", "0x02777053d6764996e594c3E88AF1D58D5363a2e6")
    const setKeeperTx = await setKeeper("Dungeons", keeper.address)
    
    async function deploySubscriptionKeeper(contractName, dungeonAddress, keeperRegistry) {
        const Keeper = await ethers.getContractFactory(contractName)
        const keeper = await Keeper.deploy(dungeonAddress, keeperRegistry)
        await keeper.deployed()
        console.log(`DungeonKeeper deployed at: ${keeper.address}`)
        return keeper
    }

    async function setKeeper(contractName, keeperAddress){
        const Contract = await ethers.getContractFactory(contractName)
        const contract = Contract.attach("")
        const set = await contract.setDungeonKeeper(keeperAddress)
        await set.wait()
        console.log(`Keeper contract has been successfuly set!`)
        return set
    }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
