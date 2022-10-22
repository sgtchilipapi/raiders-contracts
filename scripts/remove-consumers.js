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
    consumers = ["0xae6FB2655dFE926417d78AbBD309F0B9B20520A5",
    "0x10B4687C77869eBef763d7A79033715F3a08DB76",
    "0x6ee3Eb3c95672534ACE4Fa858077307Cfb38AC6f",
    "0x8daC3B63606656c70E24eCf1de6559d2Bf87dD99",
    "0x794D341e02DbB296a25604975aFAdb8D0543f25e",
    "0xf782bFB69026b58609eAc6E6eB39e6bc1b2c3876",
    "0x2F5750287c524E0F6a7c7C03C2df119Ae7d1866a",
    "0x9d03C46D230C5aE01046bDc205EEEC72bF41F090",
    "0xDB68557e64cA0732bE1B95dd87C8344fC74F36E4",
    "0x77EF098BD16714B69692B49bdEd6BebA2Fa16072",
    "0x43d7eAC9A7299d640cC5551dcF3E8D1166Bd0D7F",
    "0x198e71f88A310bBaAd9632A84D6584749b5e56eB",
    "0xD83573cb3ae207d77f49DE0da33D642bACa9FD43",
    "0x1502496f34556F775730a8c071D838b081636F8D",
    "0x0A1982D2bAa91eAC0993A2938Ba60f84Fcbf6A51",
    "0x0A131478aDD5Ac9F1AD2e4829Cd347275401ca14",
    "0xa4FADf0b32429a37f0E2635CA756F68fB5FED9AA",
    "0xA80e8916e9E9b279ee2120D13965b0860cDF4547",
    "0xd58E67aD4B83A1D05d89ADc587C0E426De663835",
    "0x0Ab0EB5A79f5C11387462e1AAa9FBB64D456f76B",
    "0xB2C26ea8CB88f8f4d510a752425189b915516A96",
    "0xc1483E488cF229EB422750F75E4D8E9735D563f5",
    "0x8A7c9232EF4a95D2921507130b5395fF0fBa2e7C",
    "0xe3302b2Bac0f3191b75c6C421Df90CE8cdC9A925",
    "0xE550b5C285879529FaA8D45fa0080e8493f39472",
    "0x4883db70cCb3501A34161b1BE96Aa64B47842Ac8",
    "0x960eb3a83E9B21fB1d85aD83B24D55daa15CF539",
    "0x20f6bE3b0eb7121Dd1AA99a43980E49717eea343",
    "0x0E95f1e0e03EFf6f57Fc201E87976E90Db41530A",
    "0xa50c49747D17F63690f1F7e892cEfc70e1B452d6",
    "0x53AA472fe38312D567e0042d3612354Ad3291e04",
    "0x2059AF74394724873F45D351D71D78d52BCCf3Ba",
    "0xdbF9BBd934889Ab65bD49e2976fea4b31eBF8836",
    "0xa741D44E1dcf46FF72d4656B84e3ec5aED0F5C92",
    "0x7988C59b3D11aea815da38FDbb3c170cBcE4532e"
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
