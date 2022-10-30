///core contracts abis
const charactersnft_artifact = require("../src/artifacts/contracts/core/nfts/Characters.sol/Characters.json")
const equipmentsnft_artifact = require("../src/artifacts/contracts/core/nfts/Equipments.sol/Equipments.json")
const dungeons_artifact = require("../src/artifacts/contracts/core/dungeons/Dungeons.sol/Dungeons.json")
const chef_artifact = require("../src/artifacts/contracts/core/defi/MiniChefV2.sol/MiniChefV2.json")
const currency_artifact = require("../src/artifacts/contracts/core/tokens/ClankToken.sol/ClankToken.json")
const materials_artifact = require("../src/artifacts/contracts/core/tokens/Materials/BoomSteel.sol/BoomSteel.json")
const catalysts_artifact = require("../src/artifacts/contracts/core/tokens/Catalysts/YellowSparkstone.sol/YellowSparkstone.json")
const consumables_artifact = require("../src/artifacts/contracts/core/tokens/Consumables/EnerLink.sol/EnerLink.json")

///periphery contracts abis
const character_minter_artifact = require("../src/artifacts/contracts/periphery/routers/CharacterMinter.sol/CharacterMinter.json")
const equipment_minter_artifact = require("../src/artifacts/contracts/periphery/routers/EquipmentMinter.sol/EquipmentMinter.json")
const character_vrf_artifact = require("../src/artifacts/contracts/periphery/chainlink/vrf/VRFv2CharacterMinting.sol/VRFv2CharacterMinting.json")
const equipment_vrf_artifact = require("../src/artifacts/contracts/periphery/chainlink/vrf/VRFv2EquipmentCrafting.sol/VRFv2EquipmentCrafting.json")
const dungeons_vrf_artifact = require("../src/artifacts/contracts/periphery/chainlink/vrf/VRFv2DungeonBattles.sol/VRFv2DungeonBattles.json")
const equipment_manager_artifact = require("../src/artifacts/contracts/periphery/equipments/EquipmentManager.sol/EquipmentManager.json")

module.exports = {
    core:{
        characters: charactersnft_artifact.abi,
        equipments: equipmentsnft_artifact.abi,
        dungeons: dungeons_artifact.abi,
        chef: chef_artifact.abi,
        tokens:{
            currency: currency_artifact.abi,
            materials: materials_artifact.abi,
            catalysts: catalysts_artifact.abi,
            consumables: consumables_artifact.abi
        }
    },
    periphery:{
        character_minter: character_minter_artifact.abi,
        equipment_minter: equipment_minter_artifact.abi,
        character_vrf: character_vrf_artifact.abi,
        equipment_vrf: equipment_vrf_artifact.abi,
        dungeons_vrf: dungeons_vrf_artifact.abi,
        equipment_manager: equipment_manager_artifact.abi
    }
}