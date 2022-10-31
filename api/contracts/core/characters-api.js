const networks = require("../../../app-config/networks")
const deployments = require("../../../app-config/deployments")
const abis = require("../../../app-config/contract-abis")
import * as connection from "../utils/connection"

///contract config
const network = networks.endpoint.testnet.http
const address = deployments.testnet_deployments.characters.nftContract.address
const abi = abis.core.characters

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
export async function getCharacterProperties(character_id){
    const contract = await getContract()
    const char_props = await contract.character(character_id)
    return char_props
}

export async function getCharacterName(character_id){
    const contract = await getContract()
    const char_name = await contract.character_name(character_id)
    return char_name
}

export async function getTokenUri(character_id){
    const contract = await getContract()
    const char_uri = await contract.tokenURI(character_id)
    return char_uri
}

///transaction functions
export async function transfer(from, to, character_id){
    const contract = await getSignedContract()
    const transferTx = await contract.transferFrom(from, to, character_id)
    const receipt = await transferTx.wait()
    return receipt
}