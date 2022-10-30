const hre = require("hardhat");
require('dotenv').config()
const characters_api = require("../../api/contracts/contracts-api")

async function main() {
  console.log(await characters_api.core.characters.view.character_properties(1))
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });