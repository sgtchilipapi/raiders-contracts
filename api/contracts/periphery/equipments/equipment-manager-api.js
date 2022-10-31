const networks = require("../../../../app-config/networks")
const deployments = require("../../../../app-config/deployments")
const abis = require("../../../../app-config/contract-abis")
import * as connection from "../../utils/connection"

///contract config
const network = networks.endpoint.testnet.http
const address = deployments.testnet_deployments.equipments.manager.address
const abi = abis.periphery.equipment_manager

///contract connections
async function getContract(){
    const contract = await connection.getContractInstance(network, address, abi)
    return contract
}

async function getSignedContract(){
    const contract = await connection.getSignedContractInstance(network, address, abi)
    return contract
}

///view functions
export async function getCharacterEquipments(character_id){
    const contract = await getContract()
    const char_eqpts = await contract.equippedWith(character_id)
    return char_eqpts
}

export async function getItemEquippedToWho(equipment_id){
    const contract = await getContract()
    const character_id = await contract.equippedTo(equipment_id)
    return character_id
}

///transaction functions
export async function equip(character_id, equipment_id){
    const contract = await getSignedContract()
    const equipTx = await contract.equip(character_id, equipment_id)
    const receipt = await equipTx.wait()
    return receipt
}

export async function equipMany(character_id, equipment_id_arr){
    const contract = await getSignedContract()
    const equipTx = await contract.equipMany(character_id, equipment_id_arr)
    const receipt = await equipTx.wait()
    return receipt
}

export async function unequipByType(character_id, equipment_type){
    const contract = await getSignedContract()
    const unequipTx = await contract.unEquipType(character_id, equipment_type)
    const receipt = await unequipTx.wait()
    return receipt
}

export async function unequipAll(character_id){
    const contract = await getSignedContract()
    const unequipTx = await contract.unEquipAll(character_id)
    const receipt = await unequipTx.wait()
    return receipt
}

