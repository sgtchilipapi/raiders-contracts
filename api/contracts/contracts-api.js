const characters_api = require("./core/characters-api")
const equipments_api = require("./core/equipments-api")

module.exports = {
    core:{
        characters: characters_api,
        equipments: equipments_api
    },
    periphery:{
        
    }
}