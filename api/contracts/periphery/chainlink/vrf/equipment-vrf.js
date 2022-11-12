const deployments = require("../../../../../app-config/deployments")
const abis = require("../../../../../app-config/contract-abis")
import * as connection from "../../../utils/connection"

///contract config
const address = deployments.contracts.equipments.vrf.address
const abi = abis.periphery.equipment_vrf

///contract connections
export async function getContract(){
    const contract = await connection.getContractInstance(address, abi)
    return contract
}

export async function getSignedContract(){
    const contract = await connection.getSignedContractInstance(address, abi)
    return contract
}

export async function getListener(){
    const contract = await connection.getListenerInstance(address, abi)
    return contract
}

///view functions
export async function getRequestStatus(request_id){
    const contract = await getContract()
    const request = await contract.s_requests(request_id)
    return request
}

///transaction functions
