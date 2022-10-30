///core contracts abis
const charactersnft_abi = require("../src/artifacts/contracts/core/nfts/Characters.sol/Characters.json")
const equipmentsnft_abi = require("../src/artifacts/contracts/core/nfts/Equipments.sol/Equipments.json")
const dungeons_abi = require("../src/artifacts/contracts/core/dungeons/Dungeons.sol/Dungeons.json")
const chef_abi = require("../src/artifacts/contracts/core/defi/MiniChefV2.sol/MiniChefV2.json")
const currency_abi = require("../src/artifacts/contracts/core/tokens/ClankToken.sol/ClankToken.json")
const materials_abi = require("../src/artifacts/contracts/core/tokens/Materials/BoomSteel.sol/BoomSteel.json")
const catalysts_abi = require("../src/artifacts/contracts/core/tokens/Catalysts/YellowSparkstone.sol/YellowSparkstone.json")
const consumables_abi = require("../src/artifacts/contracts/core/tokens/Consumables/EnerLink.sol/EnerLink.json")

///periphery contracts abis
const character_minter_abi = require("../src/artifacts/contracts/periphery/routers/CharacterMinter.sol/CharacterMinter.json")
const equipment_minter_abi = require("../src/artifacts/contracts/periphery/routers/EquipmentMinter.sol/EquipmentMinter.json")
const character_vrf_abi = require("../src/artifacts/contracts/periphery/chainlink/vrf/VRFv2CharacterMinting.sol/VRFv2CharacterMinting.json")
const equipment_vrf_abi = require("../src/artifacts/contracts/periphery/chainlink/vrf/VRFv2EquipmentCrafting.sol/VRFv2EquipmentCrafting.json")
const dungeons_vrf_abi = require("../src/artifacts/contracts/periphery/chainlink/vrf/VRFv2DungeonBattles.sol/VRFv2DungeonBattles.json")
const equipment_manager_abi = require("../src/artifacts/contracts/periphery/equipments/EquipmentManager.sol/EquipmentManager.json")

module.exports = {
    core:{
        characters: charactersnft_abi,
        equipments: equipmentsnft_abi,
        dungeons: dungeons_abi,
        chef: chef_abi,
        tokens:{
            currency: currency_abi,
            materials: materials_abi,
            catalysts: catalysts_abi,
            consumables: consumables_abi
        }
    },
    periphery:{
        character_minter: character_minter_abi,
        equipment_minter: equipment_minter_abi,
        character_vrf: character_vrf_abi,
        equipment_vrf: equipment_vrf_abi,
        dungeons_vrf: dungeons_vrf_abi,
        equipment_manager: equipment_manager_abi
    }
}