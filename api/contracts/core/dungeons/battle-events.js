export const parseData = (tx_receipt) => {
    let battle_info = {}
    let character = {}
    let enemy = {}
    let clashes = []
    for (const event of tx_receipt.events) {
        if (event.event == "BattleStarted") {
            setBattleInfo(event.args.request, battle_info)
            setCharacterInfo(event.args.char_props, event.args.char_stats, character)
            setEnemyInfo(event.args.enemy_props, event.args.enemy_stats, enemy)
        }
        if(event.event == "Clashed"){
            clashes.push(getClashInfo(event.args.clash, event.args.balances))
        }
        if(event.event == "BattleEnded"){
            battle_info.result = parseInt(event.args.battle_result)
        }
        if(event.event == "ExpAndStatGained"){
            battle_info.exp_gained = parseInt(event.args.char_gain.exp_amount)
            battle_info.stat_affected = parseInt(event.args.char_gain.stat_affected)
            battle_info.stat_amount = parseInt(event.args.char_gain.stat_amount)
        }
        if(event.event == "LootGained"){
            battle_info.material = parseInt(event.args.loot.material)
            battle_info.amount = parseInt(event.args.loot.amount)
            battle_info.snap_amount = parseInt(event.args.loot.snap_amount)
        }
    }

    const battleData = {
        battle_info: battle_info,
        char: character,
        enem: enemy,
        clashes: clashes
    }

    return battleData
}

const setBattleInfo = (info, battle_info) => {
    battle_info.id = info.request_id
    battle_info.dungeon_type = parseInt(info.dungeon_type)
    battle_info.tier = parseInt(info.tier)
    battle_info.character_id = parseInt(info.character_id)
}

const setCharacterInfo = (props, stats, character) => {
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

const setEnemyInfo = (props, stats, enemy) => {
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

const getClashInfo = (clash, bals) => {
    const characterAttack = clash.attack1
    const enemyAttack = clash.attack2
    const clashInfo = {
        char: {
            evaded: characterAttack.evaded,
            penetrated: characterAttack.penetrated,
            critical_hit: characterAttack.critical_hit,
            damage: parseInt(characterAttack.damage)
        },
        enem: {
            evaded: enemyAttack.evaded,
            penetrated: enemyAttack.penetrated,
            critical_hit: enemyAttack.critical_hit,
            damage: parseInt(enemyAttack.damage)
        },
        balances: {
            char_hp: parseInt(bals.char_hp),
            char_def: parseInt(bals.char_def),
            enem_hp: parseInt(bals.enem_hp),
            enem_def: parseInt(bals.enem_def)
        }
        
    }
    return JSON.parse(JSON.stringify(clashInfo))
}