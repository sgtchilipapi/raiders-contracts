//SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

struct battle_request {
    uint256 request_id;
    uint128 dungeon_type;
    uint128 tier;
    uint256 character_id;
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

struct clash_event {
    attack_event attack1;
    attack_event attack2;
}
