import {ethers} from 'ethers'
import Web3Modal from 'web3modal'

export async function getProvider(network){
    const provider = new ethers.providers.JsonRpcProvider(network)
    return provider
}

export async function getSigner(network){
    if(typeof window !== undefined){
        const web3Modal = new Web3Modal(network)
        const connection = await web3Modal.connect()
        const provider = new ethers.providers.Web3Provider(connection)
        const signer = provider.getSigner()
        return signer
    }
}

export async function getContractInstance(network, address, abi){
    const provider = await getProvider(network)
    const contract = new ethers.Contract(address, abi, provider)
    return contract
}

export async function getSignedContractInstance(network, address, abi){
    const signer = await getSigner(network)
    const contract = new ethers.Contract(address, abi, signer)
    return contract
}