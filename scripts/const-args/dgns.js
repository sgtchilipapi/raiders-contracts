const deployments  = require("../../app-config/deployments")

module.exports = [
    deployments.contracts.characters.nftContract.address, ///characters nft address
    deployments.contracts.equipments.nftContract.address, ///equipments nft address
    deployments.contracts.equipments.manager.address, ///equipment manager address
    [
        deployments.contracts.tokens.boom.address, ///materials tokens addresses
        deployments.contracts.tokens.thump.address,
        deployments.contracts.tokens.clink.address,
        deployments.contracts.tokens.snap.address
    ],
    deployments.contracts.tokens.enerlink.address
];

///npx hardhat verify --network <network> --constructor-args arguments.js DEPLOYED_CONTRACT_ADDRESS