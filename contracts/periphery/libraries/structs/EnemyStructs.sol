///SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

struct enemy_properties {
    uint256 dungeon;
    uint256 tier;
    uint256 _type;
    uint256 attr_sum;
    uint256 attr_alloc;
}

struct enemy_attributes {
    uint256 str;
    uint256 vit;
    uint256 dex;
}