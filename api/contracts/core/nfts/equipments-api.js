const networks = require("../../../../app-config/networks")
const deployments = require("../../../../app-config/deployments")
const abis = require("../../../../app-config/contract-abis")
import * as connection from "../../utils/connection"

///contract config
const network = networks.endpoint.testnet.http
const address = deployments.testnet_deployments.equipments.nftContract.address
const abi = abis.core.equipments

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
export async function getEquipmentProperties(equipment_id){
    const contract = await getContract()
    const eqpt_props = await contract.equipment(equipment_id)
    return eqpt_props
}

export async function getEquipmentStats(equipment_id){
    const contract = await getContract()
    const eqpt_stats = await contract.stats(equipment_id)
    return eqpt_stats
}

export async function getTokenUri(equipment_id){
    const contract = await getContract()
    const eqpt_uri = await contract.tokenURI(equipment_id)
    return eqpt_uri
}

///transaction functions
export async function transfer(from, to, equipment_id){
    const contract = await getSignedContract()
    const transferTx = await contract.transferFrom(from, to, equipment_id)
    const receipt = await transferTx.wait()
    return receipt
}