const {ethers} = require("ethers")
const Web3Modal = require('web3modal')
const networks = require("../../../app-config/networks")
const deployments = require("../../../app-config/deployments")
const abis = require("../../../app-config/contract-abis")

module.exports = {
    view:{
        character_properties: getCharacterProperties()
    },
    transaction:{

    }
}

async function getProvider(){
    const web3Modal = new Web3Modal(networks.endpoint.testnet.http)
    const connection = await web3Modal.connect()
    const provider = new ethers.providers.Web3Provider(connection)
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
async function getCharacterProperties(character_id){
    const contract = await getContractInstance()
    const char_props = await contract.character(character_id)
    return char_props
}