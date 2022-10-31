import {ethers} from 'ethers'
import Web3Modal from 'web3modal'
const networks = require("../../../app-config/networks")
const deployments = require("../../../app-config/deployments")
const abis = require("../../../app-config/contract-abis")

async function getProvider(){
    const provider = new ethers.providers.JsonRpcProvider(networks.endpoint.testnet.http)
    return provider
}

async function getSigner(){
    const provider = await getProvider()
    const signer = provider.getSigner()
    return signer
}

async function getContractInstance(){
    const provider = await getProvider()
    const contract = new ethers.Contract(deployments.testnet_deployments.characters.nftContract.address, abis.core.characters, provider)
    return contract
}

async function getSignedContractInstance(){
    const signer = await getSigner()
    const contract = new ethers.Contract(deployments.testnet_deployments.characters.nftContract.address, abis.core.characters, signer)
    return contract
}

///view functions
export async function getCharacterProperties(character_id){
    const contract = await getContractInstance()
    const char_props = await contract.character(character_id)
    return char_props
}