const connection_api = require("./utils/connection")
const characters_api = require("./core/nfts/characters-api")
const equipments_api = require("./core/nfts/equipments-api")
const equipment_manager_api = require("./periphery/equipments/equipment-manager-api")
const character_minter_api = require("./periphery/routers/character-minter-api")
const equipment_minter_api = require("./periphery/routers/equipment-minter-api")
const dungeons_api = require("./core/dungeons/dungeons-api")
const tokens_api = require("./core/tokens/tokens-api")

module.exports = {
    core:{
        ctrs: characters_api,
        eqpts: equipments_api,
        tokens: tokens_api
    },
    periphery:{
        equipments: {
            eqpt_mngr: equipment_manager_api
        },
        routers: {
            ctr_minter: character_minter_api,
            eqpt_minter: equipment_minter_api
        },
        utils: {
            connection: connection_api
        }
        

    }
}