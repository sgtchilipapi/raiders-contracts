//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../../periphery/libraries/structs/CharacterStructs.sol";
import "../../periphery/libraries/structs/EnemyStructs.sol";
import "../../periphery/libraries/structs/EquipmentStructs.sol";
import "../../periphery/libraries/structs/DungeonStructs.sol";
import "../../periphery/utils/BattleMath.sol";

interface _RandomizationContract {
    function requestRandomWords(address user) external returns (uint256 requestId);
    function getRequestStatus(uint256 _requestId) external view returns(bool fulfilled, uint256[] memory randomWords);
}
interface _Characters{
    function isOwner(address _owner, uint256 _character) external view returns (bool);
    function character(uint256 _character_id) external view returns (character_properties memory);
}

interface _Equipments{

}

interface _EquipmentManager{

}

interface _LibCharacterStatsCalculator{
    function getCharacterStats(character_properties memory properties) external pure returns (character_stats memory character);
}

interface _LibEnemyStatsCalculator{
    function getEnemyStats(uint128 dungeon_type, uint128 tier, uint16[2] memory random_numbers) external pure returns (enemy_stats memory enemy);
}

contract Dungeons is Ownable{
    _RandomizationContract vrf_contract;
    _Characters characters;
    _Equipments equipments;
    _EquipmentManager equipment_manager;
    _LibCharacterStatsCalculator character_stats_calculator;
    _LibEnemyStatsCalculator enemy_stats_calculator;

    ///The beneficiary of the msg.value being sent to the contract for every battle request.
    address vrf_refunder;

    ///The msg.value required to mint to prevent spam and deplete VRF funds
    ///Currently unset (0) for judging purposes as stated in the hackathon rules.
    uint256 battle_fee;

    ///This value represents the rate of energy restoration for every character.
    ///In this implementation, it shalle be set at 5 energy per minute.
    ///Each battle would consume 100 energy.
    uint256 private constant ENERGY_RES_RATE = 5;

    mapping(address => battle_request) public battle_requests;
    mapping(uint256 => last_energy_update) public energy_balances;

    event BattleRequested(address indexed user, battle_request request);

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
        vrf_refunder = msg.sender;
    }

    ///@notice This function initiates a battle by requesting random numbers from the VRF and setting the battle parameters:
    ///The character that would be sent into the dungeon to fight, the dungeon and the specific tier in that dungeon.
    ///Once the request is sent, the sender would not be able to send another request until the request has been fulfilled AND
    ///the battle has been completed. That is the battle has been actually played out and its effects have been reflected in the contract's state.
    function findBattle(uint256 character_id, uint128 dungeon, uint128 tier) public payable{
        ///Check for ownership of the character to be sent to battle
        require(characters.isOwner(msg.sender, character_id), "Dungeons: Character not owned");

        ///Ensure the proper parameters are sent
        require(dungeon < 3 && tier < 5, "Dungeons: Ivalid dungeon/tier");

        ///Check if enough value is being sent
        require(msg.value >= battle_fee, "Dungeons: Insufficient amount sent.");

        ///Check if the character's energy is enough
        uint256 character_energy = getCharacterEnergy(character_id);
        require(character_energy >= 100, "Dungeons: Not enough energy.");

        ///Immediately update the character's current enery
        energy_balances[character_id].energy = BattleMath.safeMinusUint256(character_energy, 100);
        energy_balances[character_id].time_last_updated = block.timestamp;


        ///Save the battle request parameters to the sender's address
        battle_requests[msg.sender] = battle_request({
            request_id: vrf_contract.requestRandomWords(msg.sender),
            dungeon_type: dungeon,
            tier: tier,
            character_id: character_id
        });

        emit BattleRequested(msg.sender, battle_requests[msg.sender]);
    }

    ///@notice This function calculates for the character's energy balance
    function getCharacterEnergy(uint256 character_id) internal view returns (uint256 character_energy){
        uint256 time_elapsed = BattleMath.safeMinusUint256(block.timestamp, energy_balances[character_id].time_last_updated);
        character_energy = BattleMath.safeAddUint256(energy_balances[character_id].energy, (time_elapsed * ENERGY_RES_RATE), 1000);
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

    ///@notice This function fetches the stats of an equipment from the Equipments NFT contract.
    function getEquipmentStats(uint256 equipment_id) internal view returns (equipment_stats memory eqpt_stats){

    }

    ///@notice This function sums up all of the equipment's stat effects.
    function getEquipmentsEffects(character_equipments memory char_eqpts) internal view returns (equipment_stats memory sum_eqpt_stats){
        combineEqptEffects(sum_eqpt_stats, getEquipmentStats(char_eqpts.headgear));
        combineEqptEffects(sum_eqpt_stats, getEquipmentStats(char_eqpts.armor));
        combineEqptEffects(sum_eqpt_stats, getEquipmentStats(char_eqpts.weapon));
        combineEqptEffects(sum_eqpt_stats, getEquipmentStats(char_eqpts.accessory));
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

    ///@notice This function consumes random numbers to pick a random enemy based from the selected dungeon parameters.
    function getEnemy(uint128 dungeon_type, uint128 tier, uint16[2] memory random_nums) internal pure returns(enemy_stats memory enemy){
 
    }


    ///@notice The following are ADMIN functions.

    function setBattleFee(uint256 amount) public onlyOwner {
        battle_fee = amount * 1 gwei;
    }

    function withdraw() public onlyOwner{
        (bool succeed, ) = vrf_refunder.call{value: address(this).balance}("");
        require(succeed, "Failed to withdraw matics.");
    }
}