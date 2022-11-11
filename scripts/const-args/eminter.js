const deployments  = require("../../app-config/deployments")

module.exports = [
    deployments.contracts.equipments.nftContract.address, ///equipments nft address
    deployments.contracts.characters.nftContract.address, ///characters nft address
    deployments.contracts.tokens.enerlink.address, ///enerlink token address
    [
        deployments.contracts.tokens.boom.address, ///materials tokens array
        deployments.contracts.tokens.thump.address,
        deployments.contracts.tokens.clink.address,
        deployments.contracts.tokens.snap.address
    ],
    [
        deployments.contracts.tokens.yellowspark.address, ///catalysts tokens array
        deployments.contracts.tokens.whitespark.address,
        deployments.contracts.tokens.redspark.address,
        deployments.contracts.tokens.bluespark.address
    ]
];

///npx hardhat verify --network <network> --constructor-args arguments.js DEPLOYED_CONTRACT_ADDRESS