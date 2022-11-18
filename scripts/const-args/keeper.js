const deployments  = require("../../app-config/deployments")

module.exports = [
    deployments.contracts.dungeons.dungeon.address, ///dungeons address
    deployments.contracts.dungeons.keeper.registry, ///keepers registry
];

///npx hardhat verify --network <network> --constructor-args arguments.js DEPLOYED_CONTRACT_ADDRESS