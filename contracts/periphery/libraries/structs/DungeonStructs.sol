//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

struct battle_request {
    uint256 request_id;
    uint64 dungeon_type;
    uint64 tier;
    uint64 result;
    uint64 max_loot;
    uint256 character_id;
    bool completed;
}

struct last_energy_update {
    uint256 energy;
    uint256 time_last_updated;
}

struct attack_event {
    bool evaded;
    bool penetrated;
    bool critical_hit;
    uint256 damage;
}

struct battlers_balances {
    uint256 char_hp;
    uint256 char_def;
    uint256 enem_hp;
    uint256 enem_def;
}

struct clash_event {
    attack_event attack1;
    attack_event attack2;
}

struct loot_gained {
    uint256 material;
    uint256 amount;
    uint256 snap_amount;
}

struct character_gained {
    uint256 exp_amount;
    uint256 stat_affected;
    uint256 stat_amount;
}
