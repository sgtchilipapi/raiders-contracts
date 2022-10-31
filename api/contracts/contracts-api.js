const characters_api = require("./core/nfts/characters-api")
const equipments_api = require("./core/nfts/equipments-api")
const equipment_manager_api = require("./periphery/equipments/equipment-manager-api")
const character_minter_api = require("./periphery/routers/character-minter-api")

module.exports = {
    core:{
        ctrs: characters_api,
        eqpts: equipments_api
    },
    periphery:{
        equipments: {
            eqpt_mngr: equipment_manager_api
        },
        routers: {
            ctr_minter: character_minter_api
        }
        

    }
}