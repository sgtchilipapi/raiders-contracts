//SPDX-License-Identifier: MIT

/**
    @title Enemy Stats Calculator
    @author Eman @SgtChiliPapi
*/

pragma solidity ^0.8.7;

import "../../libraries/structs/EnemyStructs.sol";
import "../../libraries/structs/GlobalStructs.sol";

library EnemyStatsCalculator {

    function getEnemy(uint256 dungeon_type, uint256 tier, uint16 rnum_enemy_type, uint16 rnum_attr_alloc) internal pure returns (enemy_properties memory enemy_props, battle_stats memory enemy){
        enemy_props = enemy_properties({
            dungeon: dungeon_type,
            tier: tier,
            _type: getEnemyType(rnum_enemy_type),
            attr_sum: getAttributeSum(tier),
            attr_alloc: getAttributesAllocation(rnum_attr_alloc)
        });
        enemy_attributes memory enemy_attr = getEnemyAttributes(enemy_props);
        enemy = getStats(enemy_attr, enemy_props);
    }

    function getAttributeSum(uint256 tier) internal pure returns (uint256 attr_sum){
        if(tier == 0){attr_sum = 600;}
        if(tier == 1){attr_sum = 900;}
        if(tier == 2){attr_sum = 1300;}
        if(tier == 3){attr_sum = 1800;}
        if(tier == 4){attr_sum = 2400;}
    }

    function getEnemyType(uint256 random_num) internal pure returns (uint256 enemy_type){
        enemy_type = random_num % 6;
    }

    function getAttributesAllocation(uint256 random_num) internal pure returns (uint256 attr_alloc){
        attr_alloc = (random_num % 200) + 100;
    }

    function getEnemyAttributes(enemy_properties memory enemy_props) internal pure returns (enemy_attributes memory enemy_attr){
        if(enemy_props.dungeon == 0){
            enemy_attr.str = (500 * enemy_props.attr_sum) / 1000;
            enemy_attr.vit = (enemy_props.attr_alloc * enemy_props.attr_sum) / 1000;
            enemy_attr.dex = ((500 - enemy_props.attr_alloc) * enemy_props.attr_sum) / 1000;
        }
        if(enemy_props.dungeon == 1){
            enemy_attr.str = (enemy_props.attr_alloc * enemy_props.attr_sum) / 1000;
            enemy_attr.vit = (500 * enemy_props.attr_sum) / 1000;
            enemy_attr.dex = ((500 - enemy_props.attr_alloc) * enemy_props.attr_sum) / 1000;
        }
        if(enemy_props.dungeon == 2){
            enemy_attr.str = (enemy_props.attr_alloc * enemy_props.attr_sum) / 1000;
            enemy_attr.vit = ((500 - enemy_props.attr_alloc) * enemy_props.attr_sum) / 1000;
            enemy_attr.dex = (500 * enemy_props.attr_sum) / 1000;
        }
    }

    function getStats(enemy_attributes memory enemy_attr, enemy_properties memory enemy_props) internal pure returns (battle_stats memory stats){
        stats = battle_stats({
            atk: getAttackPower(enemy_attr, enemy_props),
            def: getDefense(enemy_attr, enemy_props),
            eva: getEvasionChance(enemy_attr, enemy_props),
            hp: getHP(enemy_attr, enemy_props),
            pen: getPenetrationChance(enemy_attr, enemy_props),
            crit: getCriticalChance(enemy_attr, enemy_props),
            luck: 0,
            energy_restoration: 0
        });
    }

    function getAttackPower(enemy_attributes memory enemy_attr, enemy_properties memory enemy_props) internal pure returns (uint256 attack_power){
        attack_power = (((enemy_attr.str * 6) + (enemy_attr.dex * 4)) / 10);
        uint256 attack_bonus;
        if(enemy_props._type == 0){attack_bonus = 5;}
        attack_power += ((attack_power * attack_bonus) / 100);
    }

    function getDefense(enemy_attributes memory enemy_attr, enemy_properties memory enemy_props) internal pure returns (uint256 defense){
        defense = (((enemy_attr.vit * 6) + (enemy_attr.str * 4)) / 10) / 2;
        uint256 defense_bonus;
        if(enemy_props._type == 3){defense_bonus = 10;}
        defense += ((defense * defense_bonus) / 100);
    }

    function getEvasionChance(enemy_attributes memory enemy_attr, enemy_properties memory enemy_props) internal pure returns (uint256 evasion_chance){
        evasion_chance = (((enemy_attr.dex * 6) + (enemy_attr.vit * 4)) / 10) / 2;
        uint256 evasion_bonus;
        if(enemy_props._type == 5){evasion_bonus = 10;}
        evasion_chance += ((evasion_chance * evasion_bonus) / 100);
    }

    function getHP(enemy_attributes memory enemy_attr, enemy_properties memory enemy_props) internal pure returns (uint256 hp){
        hp = (enemy_attr.vit * 5);
        uint256 hp_bonus;
        if(enemy_props._type == 2){hp_bonus = 3;}
        hp += ((hp * hp_bonus) / 100);
    }

    function getPenetrationChance(enemy_attributes memory enemy_attr, enemy_properties memory enemy_props) internal pure returns (uint256 penetration_chance){
        penetration_chance = (enemy_attr.str / 2);
        uint256 penetration_bonus;
        if(enemy_props._type == 1){penetration_bonus = 10;}
        penetration_chance += ((penetration_chance * penetration_bonus) / 100);
    }

    function getCriticalChance(enemy_attributes memory enemy_attr, enemy_properties memory enemy_props) internal pure returns (uint256 critical_chance){
        critical_chance = (enemy_attr.dex / 2);
        uint256 critical_bonus;
        if(enemy_props._type == 4){critical_bonus = 10;}
        critical_chance += ((critical_chance * critical_bonus) / 100);
    }

}