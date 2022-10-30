const deployments  = require("../../app-config/deployments")

module.exports = [
    deployments.testnet_deployments.equipments.nftContract.address, ///equipments nft address
    deployments.testnet_deployments.characters.nftContract.address, ///characters nft address
    deployments.testnet_deployments.tokens.enerlink.address, ///enerlink token address
    [
        deployments.testnet_deployments.tokens.boom.address, ///materials tokens array
        deployments.testnet_deployments.tokens.thump.address,
        deployments.testnet_deployments.tokens.clink.address,
        deployments.testnet_deployments.tokens.snap.address
    ],
    [
        deployments.testnet_deployments.tokens.yellowspark.address, ///catalysts tokens array
        deployments.testnet_deployments.tokens.whitespark.address,
        deployments.testnet_deployments.tokens.redspark.address,
        deployments.testnet_deployments.tokens.bluespark.address
    ]
];

///npx hardhat verify --network <network> --constructor-args arguments.js DEPLOYED_CONTRACT_ADDRESS