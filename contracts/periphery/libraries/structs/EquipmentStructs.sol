///SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

struct equipment_details {
    bytes name;
    bytes image;
    bytes type_tag;
    bytes rarity_tag;
    bytes dominant_stat_tag;
    bytes extremity_tag;
}

struct equipment_properties { //SSTORED
    uint64 equipment_type; //0-3
    uint64 rarity;
    uint64 dominant_stat;
    uint64 extremity;
}

struct equipment_stats {
    uint32 atk;
    uint32 def;
    uint32 eva;
    uint32 hp;
    uint32 pen;
    uint32 crit;
    uint32 luck; //for crafting and loot
    uint32 energy_regen; //energy refund after actions
}

struct item_recipe {
    uint256 main_material;
    uint256 indirect_material;
    uint256 catalyst;
    uint256 main_material_amount;
    uint256 indirect_material_amount;
    uint256 catalyst_amount;
}

struct equipment_request { //SSTORED
    uint256 request_id;
    uint64 equipment_type;
    uint32 number_of_items;
    uint256 time_requested;
}

struct character_equipments {
    uint64 headgear;
    uint64 armor;
    uint64 weapon;
    uint64 accessory;
}