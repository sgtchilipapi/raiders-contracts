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
    const ctrs = await deployCharacters("Characters")
    const minter = await deployMinter("CharacterMinter")
    // const minter = {address: "0x00b3019DcE6bafA09A6a7E1f4103e7a143bfA81a"}
    const vrf = await deploySubscriptionVRF("VRFv2CharacterMinting", 2229, "0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed", "0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f", minter.address)
    const setMinterTx = await setMinter(ctrs, minter)
    const setVrfTx = await setVrf(minter, vrf.address)
    const addConsumer = await addVrfConsumer("VRFCoordinatorV2", 2229, "0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed", vrf.address)

    async function deployCharacters(contractName) {
        const Characters = await ethers.getContractFactory(contractName)
        const characters = await Characters.deploy()
        await characters.deployed()
        console.log(`Characters NFT deployed at: ${characters.address}`)
        return characters
    }

    async function deployMinter(contractName){
        const Minter = await ethers.getContractFactory(contractName)
        const minter = await Minter.deploy(ctrs.address)
        await minter.deployed()
        console.log(`Minter deployed at: ${minter.address}`)
        return minter
    }

    async function deploySubscriptionVRF(contractName, subscription, coordinator, keyhash, ownerContract) {
        const VRF = await ethers.getContractFactory(contractName)
        const vrf = await VRF.deploy(subscription, coordinator, keyhash, ownerContract)
        await vrf.deployed()
        console.log(`VRF deployed at: ${vrf.address}`)
        return vrf
    }

    async function setMinter(eqpts, minter){
        const set = await eqpts.setMinter(minter.address)
        await set.wait()
        console.log(`Minter has been successfuly set!`)
        return set
    }

    async function setVrf(minter, vrfAddress){
        const set = await minter.setRandomizationContract(vrfAddress)
        await set.wait()
        console.log(`VRF contract has been successfuly set!`)
        return set
    }

    async function addVrfConsumer(contractName, subscriptionId, coordinatorAddress, vrfAddress){
        const VRFCoordinatorV2 = await ethers.getContractFactory(contractName)
        const vrfCoordinator = VRFCoordinatorV2.attach(coordinatorAddress)
        const addTx = await vrfCoordinator.addConsumer(subscriptionId, vrfAddress)
        await addTx.wait()
        console.log(`VRF Consumer has been successfuly added!`)
        return addTx
    }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
