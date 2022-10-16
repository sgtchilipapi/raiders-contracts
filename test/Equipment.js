const { ethers } = require("hardhat");
const { doesNotMatch } = require("assert");

describe("Dueling System Test", function () {
    it("Testing out duel contract, attributes and stat libraries.", async function () {
        console.log("CONTRACT DEPLOYMENT")
        const [owner, player1, player2, player3] = await ethers.getSigners()

        const Equipments = await ethers.getContractFactory("Equipments")
        const equipments = await Equipments.deploy(owner.getAddress())
        await equipments.deployed()
        console.log(`Equipments deployed at: ${equipments.address}`)

        console.log("ISOLATE mintEquipments()");
        const mintTx = await equipments.mintEquipments_test()
        const txReceipt = await mintTx.wait()
        console.log(txReceipt)

    }).timeout(5000000);
});
