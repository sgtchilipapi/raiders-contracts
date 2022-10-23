//SPDX-License-Identifier: MIT
pragma solidity =0.8.17;

import "../../libraries/structs/CharacterStructs.sol";

library CharacterStatsCalculator{
    function getCharacterStats(character_properties memory properties) internal pure returns (character_stats memory stats){
        stats = character_stats({
            atk: getAttackPower(properties),
            def: getDefense(properties),
            eva: getEvasionChance(properties),
            hp: getHP(properties),
            pen: getPenetrationChance(properties),
            crit: getCriticalChance(properties),
            luck: getLuck(properties),
            energy_regen: getEnergyRegen(properties)
        });
    }

    function getAttackPower(character_properties memory properties) internal pure returns (uint256 attack_power){
        attack_power = (((properties.str * 6) + (properties.dex * 4)) / 10) / 4;
        uint256 attack_bonus;
        if(properties.character_class == 0){attack_bonus = 5;} //Viking
        attack_power += (attack_power * attack_bonus) / 100;
    }

    function getPenetrationChance(character_properties memory properties) internal pure returns (uint256 penetration_chance){
        penetration_chance = (properties.str / 2);
        uint256 penetration_bonus;
        if(properties.character_class == 1){penetration_bonus = 10;} //Woodcutter
        penetration_chance += (penetration_chance * penetration_bonus) / 100;
    }

    function getHP(character_properties memory properties) internal pure returns (uint256 hp){
        hp = (properties.vit * 5);
        uint256 hp_bonus;
        if(properties.character_class == 2){hp_bonus = 3;} //Troll
        hp += (hp * hp_bonus) / 100;
    }

    function getDefense(character_properties memory properties) internal pure returns (uint256 defense){
        defense = (((properties.vit * 6) + (properties.str * 4)) / 10) / 8;
        uint256 defense_bonus;
        if(properties.character_class == 3){defense_bonus = 10;} //Troll
        defense += (defense * defense_bonus) / 100;
    }

    function getCriticalChance(character_properties memory properties) internal pure returns (uint256 critical_chance){
        critical_chance = (properties.dex / 2);
        uint256 critical_bonus;
        if(properties.character_class == 4){critical_bonus = 10;} //Zooka
        critical_chance += (critical_chance * critical_bonus) / 100;
    }
    function getEvasionChance(character_properties memory properties) internal pure returns (uint256 evasion_chance){
        evasion_chance = (((properties.dex * 6) + (properties.vit * 4)) / 10) / 2;
        uint256 evasion_bonus;
        if(properties.character_class == 5){evasion_bonus = 10;} //Graverobber
        evasion_chance += (evasion_chance * evasion_bonus) / 100;
    }

    function getLuck(character_properties memory properties) internal pure returns (uint256 luck){
        luck = properties.dex / 10;
    }

    function getEnergyRegen(character_properties memory properties) internal pure returns (uint256 energy_regen){
        energy_regen = ((properties.vit + properties.str) / 2 ) / 10;
    }

    function getEnergyRegenBonus(character_properties memory properties) internal pure returns (uint256 energy_regen_bonus){
        if(properties.talent == 0){energy_regen_bonus = 20;}
    }

    function getCraftingBonus(character_properties memory properties) internal pure returns (uint256 crafting_bonus){
        if(properties.talent == 1){crafting_bonus = 10;}
    }

    function getLootChanceBonus(character_properties memory properties) internal pure returns (uint256 loot_chance_bonus){
        if(properties.talent == 2){loot_chance_bonus = 5;}
    }

}