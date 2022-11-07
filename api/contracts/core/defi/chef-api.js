const deployments = require("../../../../app-config/deployments")
const abis = require("../../../../app-config/contract-abis")
import * as connection from "../../utils/connection"
import {ethers} from 'ethers'

///contract config
const address = deployments.contracts.defi.minichefv2.address
const abi = abis.core.chef

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
export async function poolInfo(pool_id){
    const contract = await getContract()
    const pool = await contract.poolInfo(pool_id)
    return pool
}

export async function userInfo(pool_id, address){
    const contract = await getContract()
    const user = await contract.userInfo(pool_id, address)
    return user
}

///transaction functions
export async function deposit(pool_id, amount, addressTo){
    const contract = await getSignedContract()
    const depositTx = await contract.deposit(pool_id, amount, addressTo)
    const receipt = depositTx.wait()
    return receipt
}

export async function withdraw(pool_id, amount, addressTo){
    const contract = await getSignedContract()
    const withdrawTx = await contract.withdraw(pool_id, amount, addressTo)
    const receipt = withdrawTx.wait()
    return receipt
}

export async function harvest(pool_id, addressTo){
    const contract = await getSignedContract()
    const harvestTx = await contract.harvest(pool_id, addressTo)
    const receipt = harvestTx.wait()
    return receipt
}

export async function withdrawAndHarvest(pool_id, amount, addressTo){
    const contract = await getSignedContract()
    const withdrawTx = await contract.withdrawAndHarvest(pool_id, amount, addressTo)
    const receipt = withdrawTx.wait()
    return receipt
}

