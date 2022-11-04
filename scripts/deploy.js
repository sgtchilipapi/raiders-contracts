const { ethers } = require("hardhat");
const hre = require("hardhat");
require('dotenv').config()
const deployments  = require("../app-config/deployments")

const mainnet_config = {

}

const testnet_config = {
    tokens: deployments.contracts.tokens,
    vrf:{
        subscription: 2229,
        coordinator: "0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed",
        keyHash: "0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f"
    },
    keeper:{
        registry: "0x02777053d6764996e594c3E88AF1D58D5363a2e6"
    }
}

async function main() {
    deployAll(testnet_config)
}

async function deployAll(config){
    const [character_contract, cminter_contract] = await characters(config)
    const [equipment_contract, eminter_contract] = await equipments(config, character_contract)
    const equipment_manager  = await equipmentManager(character_contract, equipment_contract)
    const dungeons_system = await dungeons(config, character_contract, equipment_contract, equipment_manager)
    await setMinterInEnerLink(config, eminter_contract)
    await setDungeonInTokens(config, dungeons_system)
    await approveEquipmentMinter(config, eminter_contract)
}

async function characters(_config){
    const tokens = _config.tokens
    const ctrs = await deployCharacters("Characters")
    const minter = await deployMinter("CharacterMinter", tokens)
    const vrf = await deploySubscriptionVRF("VRFv2CharacterMinting", _config.vrf.subscription, _config.vrf.coordinator, _config.vrf.keyHash, minter.address)
    const setMinterTx = await setMinter(ctrs, minter)
    const setVrfTx = await setVrf(minter, vrf.address)
    const addConsumer = await addVrfConsumer("VRFCoordinatorV2", _config.vrf.subscription, _config.vrf.coordinator, vrf.address)

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

async function equipments(_config, ctrs) {
    const tokens = _config.tokens
    const eqpts = await deployEquipments("Equipments")
    const minter = await deployMinter("EquipmentMinter", tokens)
    const vrf = await deploySubscriptionVRF("VRFv2EquipmentCrafting", _config.vrf.subscription, _config.vrf.coordinator, _config.vrf.keyHash, minter.address)
    const setMinterTx = await setMinter(eqpts, minter)
    const setVrfTx = await setVrf(minter, vrf.address)
    const addConsumer = await addVrfConsumer("VRFCoordinatorV2", _config.vrf.subscription, _config.vrf.coordinator, vrf.address)

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

async function dungeons(_config, _ctrs, _eqpts, _eqpt_mgr){
    const tokens = _config.tokens
    const dgns = await deployDungeons("Dungeons", tokens)
    const vrf = await deploySubscriptionVRF("VRFv2DungeonBattles", _config.vrf.subscription, _config.vrf.coordinator, _config.vrf.keyHash, dgns.address)
    const setVrfTx = await setVrf(dgns, vrf.address)
    const addConsumer = await addVrfConsumer("VRFCoordinatorV2",  _config.vrf.subscription, _config.vrf.coordinator, vrf.address)
    const keeper = await deploySubscriptionKeeper("DungeonKeeper", dgns.address, _config.keeper.registry)
    const setKeeperTx = await setKeeper(dgns, keeper.address)

    async function deployDungeons(contractName, tokens) {
        const materials = [tokens.boom.address, tokens.thump.address, tokens.clink.address, tokens.snap.address]
        const Contract = await ethers.getContractFactory(contractName)
        const deployment = await Contract.deploy(_ctrs.address, _eqpts.address, _eqpt_mgr.address, materials, tokens.enerlink.address)
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

    async function deploySubscriptionKeeper(contractName, dungeonAddress, keeperRegistry) {
        const Keeper = await ethers.getContractFactory(contractName)
        const keeper = await Keeper.deploy(dungeonAddress, keeperRegistry)
        await keeper.deployed()
        console.log(`DungeonKeeper deployed at: ${keeper.address}`)
        return keeper
    }

    async function setKeeper(dungeonContract, keeperAddress){
        const set = await dungeonContract.setDungeonKeeper(keeperAddress)
        await set.wait()
        console.log(`Keeper contract has been successfuly set!`)
        return set
    }

    const setDungeonInCharacters = await _ctrs.setDungeon(dgns.address)
    await setDungeonInCharacters.wait()
    console.log(`Dungeons set in Characters contract successfully!`)

    return dgns
}

async function setMinterInEnerLink(_config, minter){
    const ERC20Token = await ethers.getContractFactory("EnerLink")
    await setMinter(_config.tokens.enerlink, "EnerLink")

    async function setMinter(tokenDeployment, tokenName){
        const token = ERC20Token.attach(tokenDeployment.address)
        const set = await token.setMinter(minter.address)
        await set.wait()
        console.log(`Equipment minter address set in token ${tokenName}!`)
    }
}

async function setDungeonInTokens(_config, _dungeons_system){
    const tokens = _config.tokens
    const ERC20Token = await ethers.getContractFactory("BoomSteel")
    await setDungeonToken(tokens.boom, "Boom")
    await setDungeonToken(tokens.thump, "Thump")
    await setDungeonToken(tokens.clink, "Clink")
    await setDungeonToken(tokens.snap, "Snap")

    async function setDungeonToken(tokenDeployment, tokenName){
        const token = ERC20Token.attach(tokenDeployment.address)
        const setDungeon = await token.setDungeonContract(_dungeons_system.address)
        await setDungeon.wait()
        console.log(`Dungeon address set in token ${tokenName}!`)
    }
}

async function approveEquipmentMinter(_config, _eminter_contract){
    const tokens = _config.tokens
    const ERC20Token = await ethers.getContractFactory("BoomSteel")
    await approveMinter(tokens.boom, "Boom")
    await approveMinter(tokens.thump, "Thump")
    await approveMinter(tokens.clink, "Clink")
    await approveMinter(tokens.snap, "Snap")
    await approveMinter(tokens.yellowspark, "Yspark")
    await approveMinter(tokens.whitespark, "Wspark")
    await approveMinter(tokens.redspark, "Rspark")
    await approveMinter(tokens.bluespark, "Bspark")
    

    async function approveMinter(tokenDeployment, tokenName){
        const token = ERC20Token.attach(tokenDeployment.address)
        const approveTx = await token.approve(_eminter_contract.address, ethers.utils.parseEther("1000000"))
        await approveTx.wait()
        console.log(`Minter approved for token ${tokenName}!`)
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
