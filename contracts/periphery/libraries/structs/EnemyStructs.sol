///SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

struct enemy_props {
    string name;
    string _type;
    string rank;
}
struct enemy_stats {
    uint256 atk;
    uint256 def;
    uint256 eva;
    uint256 hp;
    uint256 pen;
    uint256 crit;
    uint256 luck;
    uint256 energy_regen;
}