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
    
    ///For mumbai testnet
    consumers = [

    ]

    for(let i = 0; i < consumers.length; i++){
        await removeVrfConsumers("VRFCoordinatorV2", 2229, "0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed", consumers[i])
    }

    async function removeVrfConsumers(contractName, subscriptionId, coordinatorAddress, consumerAddress){
        const VRFCoordinatorV2 = await ethers.getContractFactory(contractName)
        const vrfCoordinator = VRFCoordinatorV2.attach(coordinatorAddress)
        const removeTx = await vrfCoordinator.removeConsumer(subscriptionId, consumerAddress)
        await removeTx.wait()
        console.log(`VRF Consumer: ${consumerAddress} has been successfuly removed!`)
        return removeTx
    }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
