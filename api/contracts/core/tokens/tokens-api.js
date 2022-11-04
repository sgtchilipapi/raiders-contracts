const networks = require("../../../../app-config/networks")
const deployments = require("../../../../app-config/deployments")
const abis = require("../../../../app-config/contract-abis")
import * as connection from "../../utils/connection"
import {ethers} from 'ethers'

///contract config
const network = networks.endpoint.testnet.http
const tokens = deployments.testnet_deployments.tokens

function getTokenAddress(token_name){
    if(token_name == "boom"){return tokens.boom.address}
    if(token_name == "thump"){return tokens.thump.address}
    if(token_name == "clink"){return tokens.clink.address}
    if(token_name == "snap"){return tokens.snap.address}
    if(token_name == "yellowspark"){return tokens.yellowspark.address}
    if(token_name == "whitespark"){return tokens.whitespark.address}
    if(token_name == "redspark"){return tokens.redspark.address}
    if(token_name == "bluespark"){return tokens.bluespark.address}
    if(token_name == "enerlink"){return tokens.enerlink.address}
    if(token_name == "clank"){return tokens.clank.address}
}

function getAbi(token_name){
    if(token_name == "boom" || token_name == "thump" || token_name == "clink" || token_name == "snap"){
        return abis.core.tokens.materials
    }
    if(token_name == "yellowspark" || token_name == "whitespark" || token_name == "redspark" || token_name == "bluespark"){
        return abis.core.tokens.catalysts
    }
    if(token_name == "enerlink"){
        return abis.core.tokens.consumables
    }
    if(token_name == "clank"){
        return abis.core.tokens.currency
    }
}

///contract connections
async function getContract(token_name){
    const address = getTokenAddress(token_name)
    const abi = getAbi(token_name)
    const contract = await connection.getContractInstance(network, address, abi)
    return contract
}

async function getSignedContract(token_name){
    const address = getTokenAddress(token_name)
    const abi = getAbi(token_name)
    const contract = await connection.getSignedContractInstance(network, address, abi)
    return contract
}

///view functions
export async function balanceOf(token_name, address){
    const contract = await getContract(token_name)
    const balance = ethers.utils.formatUnits(await contract.balanceOf(address),18)
    return balance
}

///transaction functions
export async function approve(token_name, spender, amount){
    const contract = await getSignedContract(token_name)
    const approve_tx = await contract.approve(spender, amount)
    const receipt = approve_tx.wait()
    return receipt
}

export async function transfer(token_name, to, amount){
    const contract = await getSignedContract(token_name)
    const transfer_tx = await contract.transfer(to, amount)
    const receipt = transfer_tx.wait()
    return receipt
}

///Only for the main currency $CLANK!
export async function mintFree(token_name, character_id){
    const contract = await getSignedContract(token_name)
    const mint_free_tx = await contract.mintFree(character_id)
    const receipt = mint_free_tx.wait()
    return receipt
}

