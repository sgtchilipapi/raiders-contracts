const { ethers } = require("hardhat");
const { doesNotMatch } = require("assert");

describe("Characters, Minter and VRF test.", function () {
    it("Test Character Minting", async function () {
        const [owner] = await ethers.getSigners()

        const Characters = await ethers.getContractFactory("Characters")
        const characters = await Characters.deploy()
        await characters.deployed()
        console.log(`Characters deployed at: ${characters.address}`)

        const Minter = await ethers.getContractFactory("CharacterMinter")
        const minter = await Minter.deploy(characters.address)
        await minter.deployed()
        console.log(`CharacterMinter deployed at ${minter.address}`)

        const VRF = await ethers.getContractFactory("TestVRF")
        const vrf = await VRF.deploy()
        await vrf.deployed()
        console.log(`VRF contract has been deployed!`)

        const setMinter = await characters.setMinter(minter.address)
        await setMinter.wait()
        console.log(`Minter has been successfuly set!`)
    
        const setVRF = await minter.setRandomizationContract(vrf.address)
        await setVRF.wait()
        console.log(`VRF contract has been successfuly set!`)

        const requestCharacter = await minter.requestCharacter(0, "Test Viking")
        await requestCharacter.wait()
        console.log(`Mint character request has been sent!`)

        const mintCharacter = await minter.mintCharacter()
        await mintCharacter.wait()
        console.log(`Character has been minted successfully!`)

        console.log(`Character name: ${await characters.character_name(1)}`)

    }).timeout(5000000);

    it("Test Equipment Minting", async function () {
        const [owner] = await ethers.getSigners()

        const Equipments = await ethers.getContractFactory("Equipments")
        const equipments = await Equipments.deploy()
        await equipments.deployed()
        console.log(`Equipments deployed at: ${equipments.address}`)

        const Minter = await ethers.getContractFactory("EquipmentMinter")
        const minter = await Minter.deploy(equipments.address)
        await minter.deployed()
        console.log(`EquipmentMinter deployed at ${minter.address}`)

        const VRF = await ethers.getContractFactory("TestVRF")
        const vrf = await VRF.deploy()
        await vrf.deployed()
        console.log(`VRF contract has been deployed!`)

        const setMinter = await equipments.setMinter(minter.address)
        await setMinter.wait()
        console.log(`Minter has been successfuly set!`)
    
        const setVRF = await minter.setRandomizationContract(vrf.address)
        await setVRF.wait()
        console.log(`VRF contract has been successfuly set!`)

        tokens(minter)

        const requestEquipment = await minter.requestEquipment(0, 1)
        await requestEquipment.wait()
        console.log(`Mint equipment request has been sent!`)

        const mintEquipment = await minter.mintEquipments()
        await mintEquipment.wait()
        console.log(`Equipment has been minted successfully!`)

        console.log(await equipments.equipment(1))

    }).timeout(5000000);

    async function tokens(equipment_minter){
        const clank = await deployERC20("ClankToken")
        const boom = await deployERC20("BoomSteel")
        const thump = await deployERC20("ThumpIron")
        const clink = await deployERC20("ClinkGlass")
        const snap = await deployERC20("SnapLink")
        const yellowspark = await deployERC20("YellowSparkstone")
        const whitespark = await deployERC20("WhiteSparkstone")
        const redspark = await deployERC20("RedSparkstone")
        const bluespark = await deployERC20("BlueSparkstone")

        await approveMinter(boom, "Boom")
        await approveMinter(thump, "Thump")
        await approveMinter(clink, "Clink")
        await approveMinter(snap, "Snap")
        await approveMinter(yellowspark, "Yspark")
        await approveMinter(whitespark, "Wspark")
        await approveMinter(redspark, "Rspark")
        await approveMinter(bluespark, "Bspark")

        async function deployERC20(ContractName){
            const ERC20Token = await ethers.getContractFactory(ContractName)
            const token = await ERC20Token.deploy()
            await token.deployed()
            console.log(`${ContractName} token deployed at: ${token.address}`)
            return token.address
        }

        async function approveMinter(tokenContract, tokenName){
            const approveTx = await tokenContract.approve(equipment_minter.address, ethers.utils.parseEther("1000000"))
            await approveTx.wait()
            console.log(`Equipment Minter approved for token ${tokenName}!`)
        }
    }


});
