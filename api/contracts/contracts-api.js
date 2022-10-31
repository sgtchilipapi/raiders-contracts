const characters_api = require("./core/nfts/characters-api")
const equipments_api = require("./core/nfts/equipments-api")
const equipment_manager_api = require("./periphery/equipments/equipment-manager-api")

module.exports = {
    core:{
        ctrs: characters_api,
        eqpts: equipments_api
    },
    periphery:{
        eqpt_mngr: equipment_manager_api
    }
}