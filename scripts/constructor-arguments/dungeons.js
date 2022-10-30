const deployments  = require("../../app-config/deployments")

module.exports = [
    deployments.testnet_deployments.characters.nftContract.address, ///characters nft address
    deployments.testnet_deployments.equipments.nftContract.address, ///equipments nft address
    deployments.testnet_deployments.equipments.manager.address, ///equipment manager address
    [
        deployments.testnet_deployments.tokens.boom.address, ///materials tokens addresses
        deployments.testnet_deployments.tokens.thump.address,
        deployments.testnet_deployments.tokens.clink.address,
        deployments.testnet_deployments.tokens.snap.address
    ]
];

///npx hardhat verify --network <network> --constructor-args arguments.js DEPLOYED_CONTRACT_ADDRESS