const characters_sg_api = require("./core/characters-sg")
const equipments_sg_api = require("./core/equipments-sg")

module.exports = {
    core:{
        ctrs: characters_sg_api,
        eqpts: equipments_sg_api
    },
}