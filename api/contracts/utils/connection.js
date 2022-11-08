import {ethers} from 'ethers'
import Web3Modal from 'web3modal'
const networks = require("../../../app-config/networks")
const rpcUrl = networks.endpoint.http

export async function getProvider(){
    const provider = new ethers.providers.JsonRpcProvider(rpcUrl)
    return provider
}

export async function getSigner(){
    if(typeof window !== undefined){
        const web3Modal = new Web3Modal(rpcUrl)
        const connection = await web3Modal.connect()
        const provider = new ethers.providers.Web3Provider(connection)
        const signer = provider.getSigner()
        return signer
    }
}

export async function getContractInstance(address, abi){
    const provider = await getProvider(rpcUrl)
    const contract = new ethers.Contract(address, abi, provider)
    return contract
}

export async function getSignedContractInstance(address, abi){
    const signer = await getSigner(rpcUrl)
    const contract = new ethers.Contract(address, abi, signer)
    return contract
}

export async function getListenerInstance(address, abi){
    const provider = await getProvider(rpcUrl)
    provider.pollingInterval = 1000;
    const contract = new ethers.Contract(address, abi, provider)
    return contract
}