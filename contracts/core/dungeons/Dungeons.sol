//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../../periphery/libraries/structs/CharacterStructs.sol";
import "../../periphery/libraries/structs/EnemyStructs.sol";
import "../../periphery/libraries/structs/EquipmentStructs.sol";

interface _Characters{

}

interface _Equipments{

}

interface _EquipmentManager{

}

interface _LibCharacterStatsCalculator{
    function getCharacterStats(character_properties memory properties) external pure returns (character_stats memory character);
}

interface _LibEnemyStatsCalculator{
    function getEnemyStats(uint256 dungeon_type, uint256 tier, uint16[2] memory random_numbers) external pure returns (enemy_stats memory enemy);
}

contract Dungeons is Ownable{
    _Characters characters;
    _Equipments equipments;
    _EquipmentManager equipment_manager;
    _LibCharacterStatsCalculator character_stats_calculator;
    _LibEnemyStatsCalculator enemy_stats_calculator;

    constructor(
        address charactersNftAddress, 
        address equipmentNftAddress, 
        address equipmentManagerAddress,
        address libCharacterStatsCalculatorAddress,
        address libEnemyStatsCalculatorAddress
    ){
        characters = _Characters(charactersNftAddress);
        equipments = _Equipments(equipmentNftAddress);
        equipment_manager = _EquipmentManager(equipmentManagerAddress);
        character_stats_calculator = _LibCharacterStatsCalculator(libCharacterStatsCalculatorAddress);
        enemy_stats_calculator = _LibEnemyStatsCalculator(libEnemyStatsCalculatorAddress);
    }

    ///@notice This function requests for the random numbers from the VRF.
    function enter(uint256 character_id, uint256 dungeon, uint256 tier) public {

    }

    ///@notice This function consumes random numbers to pick a random enemy based the selected dungeon parameters.
    function getEnemy(uint256 dungeon_type, uint256 tier, uint16[2] memory random_nums) internal pure returns(enemy_stats memory enemy){
 
    }

    ///@notice This function fetches the character's properties from the Characterse NFT contract.
    function getCharacterProperties(uint256 character_id) internal view returns(character_properties memory char_props){

    }

    ///@notice This function calculates the stats of the chosen character.
    function getCharacterStats(character_properties memory char_props, equipment_stats memory sum_eqpt_stats) internal pure returns(character_stats memory char_stats){
        //
        combineStatEffects(char_stats, sum_eqpt_stats);
    }

    ///@notice This function fetches the character's equipped stats.
    function getEquipments(uint256 character_id) internal view returns (character_equipments memory char_eqpts){

    }

    ///@notice This function sums up all of the equipment's stat effects.
    function getEquipmentsEffects(character_equipments memory char_eqpts) internal view returns (equipment_stats memory sum_eqpt_stats){
        combineEqptEffects(sum_eqpt_stats, getEquipmentStats(char_eqpts.headgear));
        combineEqptEffects(sum_eqpt_stats, getEquipmentStats(char_eqpts.armor));
        combineEqptEffects(sum_eqpt_stats, getEquipmentStats(char_eqpts.weapon));
        combineEqptEffects(sum_eqpt_stats, getEquipmentStats(char_eqpts.accessory));
    }

    ///@notice This function fetches the stats of an equipment from the Equipments NFT contract.
    function getEquipmentStats(uint256 equipment_id) internal view returns (equipment_stats memory eqpt_stats){

    }

    ///@notice This function combines the stat effects of 2 set of equipment stats by directly mutating the first set.
    function combineEqptEffects(equipment_stats memory stats1, equipment_stats memory stats2) internal pure{
        stats1.atk += stats2.atk;
        stats1.def += stats2.def;
        stats1.eva += stats2.eva;
        stats1.hp += stats2.hp;
        stats1.pen += stats2.pen;
        stats1.crit += stats2.crit;
        stats1.luck += stats2.luck;
        stats1.energy_regen += stats2.energy_regen;
    }

    ///@notice This function combines the stat effects of 2 set of stats by directly mutating the first set.
    function combineStatEffects(character_stats memory stats1, equipment_stats memory stats2) internal pure{
        stats1.atk += stats2.atk;
        stats1.def += stats2.def;
        stats1.eva += stats2.eva;
        stats1.hp += stats2.hp;
        stats1.pen += stats2.pen;
        stats1.crit += stats2.crit;
        stats1.luck += stats2.luck;
        stats1.energy_regen += stats2.energy_regen;
    }
}