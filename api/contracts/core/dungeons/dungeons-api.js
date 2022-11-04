const networks = require("../../../../app-config/networks")
const deployments = require("../../../../app-config/deployments")
const abis = require("../../../../app-config/contract-abis")
import * as connection from "../../utils/connection"

///contract config
const network = networks.endpoint.testnet.http
const address = deployments.testnet_deployments.dungeons.dungeon.address
const abi = abis.core.dungeons

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
export async function getBattleRequest(address){
    const contract = await getContract()
    const request = await contract.battle_requests(address)
    return request
}

export async function getCharacterEnergy(character_id){
    const contract = await getContract()
    const char_energy = await contract.getCharacterEnergy(character_id)
    return char_energy
}

///transaction functions
export async function findBattle(character_id, dungeon, tier){
    const contract = await getSignedContract()
    const find_battle_tx = await contract.findBattle(character_id, dungeon, tier)
    const receipt = find_battle_tx.wait()
    return receipt
}

export async function startBattle(){
    const contract = await getSignedContract()
    const start_battle_tx = await contract.startBattle()
    const receipt = start_battle_tx.wait()
    return receipt
}

export async function consumeEnerLink(character_id){
    const contract = await getSignedContract()
    const consume_enerlink_tx = await contract.consumeEnerLink(character_id)
    const receipt = consume_enerlink_tx.wait()
    return receipt
}

