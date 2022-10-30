// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers } = require("hardhat");
const hre = require("hardhat");
require('dotenv').config()
const deployments  = require("../contracts-apis/deployments")

async function main() {
    const [character_contract, cminter_contract] = await characters()
    const [equipment_contract, eminter_contract] = await equipments(character_contract)
    const equipment_manager  = await equipmentManager(character_contract, equipment_contract)
    const dungeons_system = await dungeons(character_contract, equipment_contract, equipment_manager)
    await setMinterInEnerLink(eminter_contract)
    await setDungeonInTokens(dungeons_system)
    await approveEquipmentMinter(eminter_contract)
}

async function characters(){
    ///For MATIC mainnet
    ///const mainnetVRF = await deploySubscriptionVRF("VRFv2Consumer", 0, "0xAE975071Be8F8eE67addBC1A82488F1C24858067", "0xcc294a196eeeb44da2888d17c0625cc88d70d9760a69d58d853ba6581a9ab0cd")

    ///For mumbai testnet
    const tokens = deployments.testnet_deployments.tokens
    const ctrs = await deployCharacters("Characters")
    const minter = await deployMinter("CharacterMinter", tokens)
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

    return [ctrs, minter]
}

async function equipments(ctrs) {
    ///For MATIC mainnet
    ///const mainnetVRF = await deploySubscriptionVRF("VRFv2Consumer", 0, "0xAE975071Be8F8eE67addBC1A82488F1C24858067", "0xcc294a196eeeb44da2888d17c0625cc88d70d9760a69d58d853ba6581a9ab0cd")

    ///For mumbai testnet
    const tokens = deployments.testnet_deployments.tokens
    const eqpts = await deployEquipments("Equipments")
    const minter = await deployMinter("EquipmentMinter", tokens)
    const vrf = await deploySubscriptionVRF("VRFv2EquipmentCrafting", 2229, "0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed", "0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f", minter.address)
    const setMinterTx = await setMinter(eqpts, minter)
    const setVrfTx = await setVrf(minter, vrf.address)
    const addConsumer = await addVrfConsumer("VRFCoordinatorV2", 2229, "0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed", vrf.address)

    async function deployEquipments(contractName) {
        const Equipments = await ethers.getContractFactory(contractName)
        const equipments = await Equipments.deploy()
        await equipments.deployed()
        console.log(`Equipment deployed at: ${equipments.address}`)
        return equipments
    }

    async function deployMinter(contractName, tokens){
        const materials = [tokens.boom.address, tokens.thump.address, tokens.clink.address, tokens.snap.address]
        const catalysts = [tokens.yellowspark.address, tokens.whitespark.address, tokens.redspark.address, tokens.bluespark.address]
        const EquipmentMinter = await ethers.getContractFactory(contractName)
        const equipmentMinter = await EquipmentMinter.deploy(eqpts.address, ctrs.address, tokens.enerlink.address, materials, catalysts)
        await equipmentMinter.deployed()
        console.log(`EquipmentMinter deployed at: ${equipmentMinter.address}`)
        return equipmentMinter
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

    return [eqpts, minter]
}

async function equipmentManager(ctrs, eqpts) {
    ///For MATIC mainnet
   
    ///For mumbai testnet
    const eqpt_manager = await deployManager("EquipmentManager")
    const manager_ctrs = await setManagerInCTRS(eqpt_manager)
    const manager_eqpts = await setManagerInEQPTS(eqpt_manager)

    async function deployManager(contractName) {
        const EquipmentManager = await ethers.getContractFactory(contractName)
        const manager = await EquipmentManager.deploy(ctrs.address, eqpts.address)
        await manager.deployed()
        console.log(`EquipmentManger deployed at: ${manager.address}`)
        return manager
    }

    async function setManagerInCTRS(){
        const setManager = await ctrs.setEquipmentManager(eqpt_manager.address)
        await setManager.wait()
        console.log(`EquipmentManager set in CTRS!`)
    }

    async function setManagerInEQPTS(){
        const setManager = await eqpts.setEquipmentManager(eqpt_manager.address)
        await setManager.wait()
        console.log(`EquipmentManager set in EQPTS!`)
    }

    return eqpt_manager
}

async function dungeons(_ctrs, _eqpts, _eqpt_mgr){
    ///For MATIC mainnet
    ///const mainnetVRF = await deploySubscriptionVRF("VRFv2Consumer", 0, "0xAE975071Be8F8eE67addBC1A82488F1C24858067", "0xcc294a196eeeb44da2888d17c0625cc88d70d9760a69d58d853ba6581a9ab0cd")

    ///For mumbai testnet
    const tokens = deployments.testnet_deployments.tokens
    const dgns = await deployDungeons("Dungeons", tokens)
    const vrf = await deploySubscriptionVRF("VRFv2DungeonBattles", 2229, "0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed", "0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f", dgns.address)
    const setVrfTx = await setVrf(dgns, vrf.address)
    const addConsumer = await addVrfConsumer("VRFCoordinatorV2", 2229, "0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed", vrf.address)

    async function deployDungeons(contractName, tokens) {
        const materials = [tokens.boom.address, tokens.thump.address, tokens.clink.address, tokens.snap.address]
        const Contract = await ethers.getContractFactory(contractName)
        const deployment = await Contract.deploy(_ctrs.address, _eqpts.address, _eqpt_mgr.address, materials)
        await deployment.deployed()
        console.log(`Dungeons deployed at: ${deployment.address}`)
        return deployment
    }

    async function deploySubscriptionVRF(contractName, subscription, coordinator, keyhash, ownerContract) {
        const VRF = await ethers.getContractFactory(contractName)
        const vrf = await VRF.deploy(subscription, coordinator, keyhash, ownerContract)
        await vrf.deployed()
        console.log(`VRF deployed at: ${vrf.address}`)
        return vrf
    }

    async function setVrf(ownerContract, vrfAddress){
        const set = await ownerContract.setRandomizationContract(vrfAddress)
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

    const setDungeonInCharacters = await _ctrs.setDungeon(dgns.address)
    await setDungeonInCharacters.wait()
    console.log(`Dungeons set in Characters contract successfully!`)

    return dgns
}

async function setMinterInEnerLink(minter){
    ///For MATIC mainnet
    ///const mainnetVRF = await deploySubscriptionVRF("VRFv2Consumer", 0, "0xAE975071Be8F8eE67addBC1A82488F1C24858067", "0xcc294a196eeeb44da2888d17c0625cc88d70d9760a69d58d853ba6581a9ab0cd")

    ///For mumbai testnet
    const ERC20Token = await ethers.getContractFactory("EnerLink")
    await setMinter(deployments.testnet_deployments.tokens.enerlink, "EnerLink")

    async function setMinter(tokenDeployment, tokenName){
        const token = ERC20Token.attach(tokenDeployment.address)
        const set = await token.setMinter(minter.address)
        await set.wait()
        console.log(`Equipment minter address set in token ${tokenName}!`)
    }
}

async function setDungeonInTokens(_dungeons_system){
    ///For MATIC mainnet
    ///const mainnetVRF = await deploySubscriptionVRF("VRFv2Consumer", 0, "0xAE975071Be8F8eE67addBC1A82488F1C24858067", "0xcc294a196eeeb44da2888d17c0625cc88d70d9760a69d58d853ba6581a9ab0cd")

    ///For mumbai testnet
    const ERC20Token = await ethers.getContractFactory("BoomSteel")
    await setDungeonToken(deployments.testnet_deployments.tokens.boom, "Boom")
    await setDungeonToken(deployments.testnet_deployments.tokens.thump, "Thump")
    await setDungeonToken(deployments.testnet_deployments.tokens.clink, "Clink")
    await setDungeonToken(deployments.testnet_deployments.tokens.snap, "Snap")

    async function setDungeonToken(tokenDeployment, tokenName){
        const token = ERC20Token.attach(tokenDeployment.address)
        const setDungeon = await token.setDungeonContract(_dungeons_system.address)
        await setDungeon.wait()
        console.log(`Dungeon address set in token ${tokenName}!`)
    }
}

async function approveEquipmentMinter(_eminter_contract){
    ///For MATIC mainnet
    ///const mainnetVRF = await deploySubscriptionVRF("VRFv2Consumer", 0, "0xAE975071Be8F8eE67addBC1A82488F1C24858067", "0xcc294a196eeeb44da2888d17c0625cc88d70d9760a69d58d853ba6581a9ab0cd")

    ///For mumbai testnet
    const ERC20Token = await ethers.getContractFactory("BoomSteel")
    await approveMinter(deployments.testnet_deployments.tokens.boom, "Boom")
    await approveMinter(deployments.testnet_deployments.tokens.thump, "Thump")
    await approveMinter(deployments.testnet_deployments.tokens.clink, "Clink")
    await approveMinter(deployments.testnet_deployments.tokens.snap, "Snap")
    await approveMinter(deployments.testnet_deployments.tokens.yellowspark, "Yspark")
    await approveMinter(deployments.testnet_deployments.tokens.whitespark, "Wspark")
    await approveMinter(deployments.testnet_deployments.tokens.redspark, "Rspark")
    await approveMinter(deployments.testnet_deployments.tokens.bluespark, "Bspark")
    

    async function approveMinter(tokenDeployment, tokenName){
        const token = ERC20Token.attach(tokenDeployment.address)
        const approveTx = await token.approve(_eminter_contract.address, ethers.utils.parseEther("1000000"))
        await approveTx.wait()
        console.log(`Minter approved for token ${tokenName}!`)
    }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
