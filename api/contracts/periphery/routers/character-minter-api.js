const networks = require("../../../../app-config/networks")
const deployments = require("../../../../app-config/deployments")
const abis = require("../../../../app-config/contract-abis")
import * as connection from "../../utils/connection"
import { ethers } from "ethers"

///contract config
const network = networks.endpoint.testnet.http
const address = deployments.testnet_deployments.characters.minter.address
const abi = abis.periphery.character_minter

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
export async function getRequest(address){
    const contract = await getContract()
    const request = await contract.request(address)
    return request
}

///transaction functions
export async function requestCharacter(character_class, character_name, value){
    const msgvalue = ethers.utils.parseEther(value)
    const contract = await getSignedContract()
    const requestTx = await contract.requestCharacter(character_class, character_name, {value: msgvalue})
    const receipt = await requestTx.wait()
    return receipt
}

export async function mintCharacter(){
    const contract = await getSignedContract()
    const mintTx = await contract.mintCharacter()
    const receipt = await mintTx.wait()
    return receipt
}

export async function requestCharacterExperimental(character_class, character_name, value){
    const msgvalue = ethers.utils.parseEther(value)
    const contract = await getSignedContract()
    const requestTx = await contract.requestCharacterExperimental(character_class, character_name, {value: msgvalue})
    const receipt = await requestTx.wait()
    return receipt
}

export async function cancelRequestExperimental(){
    const contract = await getSignedContract()
    const cancelTx = await contract.cancelRequestExperimental()
    const receipt = await cancelTx.wait()
    return receipt
}

