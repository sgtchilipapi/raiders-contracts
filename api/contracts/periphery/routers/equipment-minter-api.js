const deployments = require("../../../../app-config/deployments")
const abis = require("../../../../app-config/contract-abis")
import * as connection from "../../utils/connection"
import { ethers } from "ethers"

///contract config
const address = deployments.contracts.equipments.minter.address
const abi = abis.periphery.equipment_minter

///contract connections
async function getContract(){
    const contract = await connection.getContractInstance(address, abi)
    return contract
}

async function getSignedContract(){
    const contract = await connection.getSignedContractInstance(address, abi)
    return contract
}

///view functions
export async function getRequest(address){
    const contract = await getContract()
    const request = await contract.request(address)
    return request
}

export async function characterMintedFree(character_id){
    const contract = await getContract()
    const minted_free = await contract.character_minted_free(character_id)
    return minted_free
}

export async function mintFee(){
    const contract = await getContract()
    const minted_free = ethers.utils.formatUnits(await contract.mint_fee(), 18)
    return minted_free
}

export async function getEquipmentRecipe(type){
    const contract = await getContract()
    const recipe = await contract.getEquipmentRecipe(type)
    return recipe
}

export async function userMaterialsEnough(type, count){
    const contract = await getContract()
    const enough = await contract.userMaterialsEnough(type, count)
    return enough
}

///transaction functions
export async function requestEquipment(type, count, value){
    const msgvalue = ethers.utils.parseEther(value)
    const contract = await getSignedContract()
    const gas = parseInt(await contract.estimateGas.requestEquipment(type, count, {value: msgvalue}) * 1.15) ///Add 15% to heighten tx confirm chance
    const parsedGas = ethers.utils.parseUnits(gas.toString(), "wei")
    const requestTx = await contract.requestEquipment(type, count, {value: msgvalue, gasLimit: parsedGas})
    const receipt = await requestTx.wait()
    return receipt
    
}

export async function requestEquipmentExperimental(type, value){
    const msgvalue = ethers.utils.parseEther(value)
    const contract = await getSignedContract()
    const gas = parseInt(await contract.estimateGas.requestEquipmentExperimental(type, {value: msgvalue}) * 1.15) ///Add 15% to heighten tx confirm chance
    const parsedGas = ethers.utils.parseUnits(gas.toString(), "wei")
    const requestTx = await contract.requestEquipmentExperimental(type, {value: msgvalue, gasLimit: parsedGas})
    const receipt = await requestTx.wait()
    return receipt
}

export async function requestEquipmentExperimentalFree(character_id, type, value){
    const msgvalue = ethers.utils.parseEther(value)
    const contract = await getSignedContract()
    const gas = parseInt(await contract.estimateGas.requestEquipmentExperimentalFree(character_id, type, {value: msgvalue}) * 1.15) ///Add 15% to heighten tx confirm chance
    const parsedGas = ethers.utils.parseUnits(gas.toString(), "wei")
    const requestTx = await contract.requestEquipmentExperimentalFree(character_id, type, {value: msgvalue, gasLimit: parsedGas})
    const receipt = await requestTx.wait()
    return receipt
}

export async function cancelRequestExperimental(){
    const contract = await getSignedContract()
    const cancelTx = await contract.cancelRequestExperimental()
    const receipt = await cancelTx.wait()
    return receipt
}

export async function mintEquipments(){
    const contract = await getSignedContract()
    const gas = parseInt(await contract.estimateGas.mintEquipments() * 1.15) ///Add 15% to heighten tx confirm chance
    const parsedGas = ethers.utils.parseUnits(gas.toString(), "wei")
    const mintTx = await contract.mintEquipments({gasLimit: parsedGas})
    const receipt = await mintTx.wait()
    return receipt
}

