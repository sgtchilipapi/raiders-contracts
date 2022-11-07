const deployments = require("../../../../app-config/deployments")
const abis = require("../../../../app-config/contract-abis")
import * as connection from "../../utils/connection"
import { ethers } from "ethers"

///contract config
const address = deployments.contracts.characters.minter.address
const abi = abis.periphery.character_minter

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

///transaction functions
export async function requestCharacter(character_class, character_name, value){
    const msgvalue = ethers.utils.parseEther(value)
    const contract = await getSignedContract()
    const gas = parseInt(await contract.estimateGas.requestCharacter(character_class, character_name, {value: msgvalue}) * 1.15) ///Add 15% to heighten tx confirm chance
    const parsedGas = ethers.utils.parseUnits(gas.toString(), "wei")
    const requestTx = await contract.requestCharacter(character_class, character_name, {value: msgvalue, gasLimit: parsedGas})
    const receipt = await requestTx.wait()
    return receipt
}

export async function requestCharacterExperimental(character_class, character_name, value){
    const msgvalue = ethers.utils.parseEther(value)
    const contract = await getSignedContract()
    const gas = parseInt(await contract.estimateGas.requestCharacterExperimental(character_class, character_name, {value: msgvalue}) * 1.15) ///Add 15% to heighten tx confirm chance
    const parsedGas = ethers.utils.parseUnits(gas.toString(), "wei")
    const requestTx = await contract.requestCharacterExperimental(character_class, character_name, {value: msgvalue, gasLimit: parsedGas})
    const receipt = await requestTx.wait()
    return receipt
}

export async function cancelRequestExperimental(){
    const contract = await getSignedContract()
    const cancelTx = await contract.cancelRequestExperimental()
    const receipt = await cancelTx.wait()
    return receipt
}

export async function mintCharacter(){
    const contract = await getSignedContract()
    const gas = parseInt(await contract.estimateGas.mintCharacter() * 1.15) ///Add 15% to heighten tx confirm chance
    const parsedGas = ethers.utils.parseUnits(gas.toString(), "wei")
    const mintTx = await contract.mintCharacter({gasLimit: parsedGas})
    const receipt = await mintTx.wait()
    return receipt
}

