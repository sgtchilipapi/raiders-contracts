let battle_info = {}
let character = {}
let enemy = {}
let clashes = []

export const parseData = (tx_receipt) => {

    for (const event of tx_receipt.events) {
        if (event.event == "BattleStarted") {
            setBattleInfo(event.args.request)
            setCharacterInfo(event.args.char_props, event.args.char_stats)
            setEnemyInfo(event.args.enemy_props, event.args.enemy_stats)
        }
        if(event.event == "Clashed"){
            clashes.push(getClashInfo(event.args.clash))
        }
        if(event.event == "BattleEnded"){
            battle_info.result = parseInt(event.args.battle_result)
        }
    }

    const battleData = {
        battle_info: battle_info,
        character_info: character,
        enemy_info: enemy,
        clashes: clashes
    }

    return battleData
}

const setBattleInfo = (info) => {
    battle_info.id = info.request_id
    battle_info.dungeon_type = parseInt(info.dungeon_type)
    battle_info.tier = parseInt(info.tier)
    battle_info.character_id = parseInt(info.character_id)
}

const setCharacterInfo = (props, stats) => {
    character.character_class = parseInt(props.character_class)
    character.atk = parseInt(stats.atk)
    character.def = parseInt(stats.def)
    character.eva = parseInt(stats.eva)
    character.hp = parseInt(stats.hp)
    character.pen = parseInt(stats.pen)
    character.crit = parseInt(stats.crit)
    character.luk = parseInt(stats.luck)
    character.res = parseInt(stats.energy_restoration)
}

const setEnemyInfo = (props, stats) => {
    enemy.enemy_class = parseInt(props._type)
    enemy.atk = parseInt(stats.atk)
    enemy.def = parseInt(stats.def)
    enemy.eva = parseInt(stats.eva)
    enemy.hp = parseInt(stats.hp)
    enemy.pen = parseInt(stats.pen)
    enemy.crit = parseInt(stats.crit)
    enemy.luk = parseInt(stats.luck)
    enemy.res = parseInt(stats.energy_restoration)
}

const getClashInfo = (clash) => {
    const characterAttack = clash.attack1
    const enemyAttack = clash.attack2
    const clashInfo = {
        character_attack: {
            evaded: characterAttack.evaded,
            penetrated: characterAttack.penetrated,
            critical_hit: characterAttack.critical_hit,
            damage: parseInt(characterAttack.damage)
        },
        enemy_attack: {
            evaded: enemyAttack.evaded,
            penetrated: enemyAttack.penetrated,
            critical_hit: enemyAttack.critical_hit,
            damage: parseInt(enemyAttack.damage)
        }
    }
    return JSON.parse(JSON.stringify(clashInfo))
}