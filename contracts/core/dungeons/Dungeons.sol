//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../../periphery/libraries/structs/CharacterStructs.sol";
import "../../periphery/libraries/structs/EnemyStructs.sol";
import "../../periphery/libraries/structs/GlobalStructs.sol";
import "../../periphery/libraries/structs/EquipmentStructs.sol";
import "../../periphery/libraries/structs/DungeonStructs.sol";
import "../../periphery/libraries/characters/CharacterStatsCalculator.sol";
import "../../periphery/libraries/enemies/EnemyStatsCalculator.sol";
import "../../periphery/utils/BattleMath.sol";
import "../../periphery/utils/BreakdownUint256.sol";

interface _RandomizationContract {
    function requestRandomWords(address user, uint32 numWords) external returns (uint256 requestId);
    function getRequestStatus(uint256 _requestId) external view returns(bool fulfilled, uint256[] memory randomWords);
}
interface _Characters{
    function isOwner(address _owner, uint256 _character) external view returns (bool);
    function character(uint256 _character_id) external view returns (character_properties memory);
}

interface _Equipments{
    function stats(uint256 _equipment_id) external view returns (battle_stats memory);
}

interface _EquipmentManager{
    function equippedWith(uint256 character_id) external view returns (character_equipments memory);
}

interface _LibCharacterStatsCalculator{
    function getCharacterStats(character_properties memory properties) external pure returns (battle_stats memory character);
}

interface _LibEnemyStatsCalculator{
    function getEnemyStats(uint128 dungeon_type, uint128 tier, uint16[2] memory random_numbers) external pure returns (battle_stats memory enemy);
}


///@notice This contract keeps track of pending PVE battles and provides logic for completing them.
///A battle consists of two (2) steps/transactions from the player:
///1. Request a battle using `findBattle()` - Its main function is to request random numbers from the VRF.
///2. Fulfill the battle request using `startBattle()` - Its main function is to simulate the battle on-chain and to apply the 
///effects of the battle result.

contract Dungeons is Ownable{
    _RandomizationContract private vrf_contract;
    _Characters private characters;
    _Equipments private equipments;
    _EquipmentManager private equipment_manager;
    // _LibCharacterStatsCalculator character_stats_calculator;
    // _LibEnemyStatsCalculator enemy_stats_calculator;

    ///The beneficiary of the msg.value being sent to the contract for every battle request.
    address private vrf_refunder;

    ///The msg.value required to mint to prevent spam and deplete VRF funds
    ///Currently unset (0) for judging purposes as stated in the hackathon rules.
    uint256 private battle_fee;

    ///This value represents the rate of energy restoration for every character.
    ///In this implementation, it shall be set at 5 energy per minute.
    ///Each battle would consume 100 energy.
    uint256 private constant ENERGY_RES_RATE = 5;

    ///This maps the battle requests made to the senders who made them. Only one request per sender is allowed.
    ///Once the sender has an outstanding request, he/she should complete the battle before sending another request.
    mapping(address => battle_request) public battle_requests;

    ///
    mapping(uint256 => last_energy_update) public energy_balances;

    event BattleRequested(address indexed user, battle_request request);

    constructor(
        address charactersNftAddress, 
        address equipmentNftAddress, 
        address equipmentManagerAddress
        // address libCharacterStatsCalculatorAddress,
        // address libEnemyStatsCalculatorAddress
    ){
        characters = _Characters(charactersNftAddress);
        equipments = _Equipments(equipmentNftAddress);
        equipment_manager = _EquipmentManager(equipmentManagerAddress);
        // character_stats_calculator = _LibCharacterStatsCalculator(libCharacterStatsCalculatorAddress);
        // enemy_stats_calculator = _LibEnemyStatsCalculator(libEnemyStatsCalculatorAddress);
        vrf_refunder = msg.sender;
    }

    ///@notice This function initiates a battle by requesting random numbers from the VRF and setting the battle parameters:
    ///The character that would be sent into the dungeon to fight, the dungeon and the specific tier in that dungeon.
    ///Once the request is sent, the sender would not be able to send another request until the request has been fulfilled AND
    ///the battle has been completed. That is the battle has been actually played out and its effects have been reflected in the contract's state.
    function findBattle(uint256 character_id, uint128 dungeon, uint128 tier) public payable{
        ///Ensure ownership of the character to be sent to battle
        require(characters.isOwner(msg.sender, character_id), "Dungeons: Character not owned");

        ///Ensure the proper parameters are sent
        require(dungeon < 3 && tier < 5, "Dungeons: Ivalid dungeon/tier");

        ///Ensure that enough value is being sent
        require(msg.value >= battle_fee, "Dungeons: Insufficient amount sent.");

        ///Ensure that the character's energy is enough
        uint256 character_energy = getCharacterEnergy(character_id);
        require(character_energy >= 100, "Dungeons: Not enough energy.");

        ///Update the character's current energy immediately
        energy_balances[character_id].energy = BattleMath.safeMinusUint256(character_energy, 100);
        energy_balances[character_id].time_last_updated = block.timestamp;


        ///Map the battle request parameters to the sender's address
        battle_requests[msg.sender] = battle_request({
            request_id: vrf_contract.requestRandomWords(msg.sender, 11),
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

    ///@notice This function completes the battle and reflects its effects in the contract's state.
    function startBattle() public {
        ///Load the sender's previous request
        battle_request memory request = battle_requests[msg.sender];

        ///Get the status of the randomWords using the request's id
        (bool fulfilled, uint256[] memory random_words) = vrf_contract.getRequestStatus(request.request_id);
        require(fulfilled, "Dungeons: Not yet fulfilled.");

        ///Break 1 uint256 randomWord into 16 uint16 numbers for calculating battle contingencies.
        uint16[] memory random_set1 = BreakdownUint256.break256BitsIntegerIntoBytesArrayOf16Bits(random_words[0]);

        ///Get the properties of the character primarily to determine character class.
        ///Get the stats of the character using the request's character_id property value.
        (character_properties memory char_props, battle_stats memory char_stats) = getCharacter(request.character_id);

        ///Calculate the enemy's stats within the requests parameters and 2 random uint16s
        (enemy_properties memory enem_props, battle_stats memory enem_stats) = EnemyStatsCalculator.getEnemy(request.dungeon_type, request.tier, random_set1[0], random_set1[1]);

        ///Simulate the actual battle
        uint256 battle_result = simulateBattle(char_props, char_stats, enem_props, enem_stats, random_words);

        ///@dev EXTCALL: Write to Character NFT contract the character's gain in experience and attributes from the battle if any.
        applyCharacterEffects(request, random_set1[2]);
    }

    ///@notice This function fetches the character properties, stats and equipment and returns only the stats for use in battle.
    function getCharacter(uint256 character_id) internal view returns (character_properties memory char_props, battle_stats memory char_stats){
        ///Get the character properties from the Characters NFT contract
        char_props = characters.character(character_id);

        ///Calculate the stats of the character using its properties
        char_stats = CharacterStatsCalculator.getCharacter(char_props);

        ///Calculate the sum of all stats of the character's current equipments.
        battle_stats memory sum_eqpt_stats = getEquipmentsEffects(character_id);

        ///Mutate `char_stats` directly to combine the bare character stats and the sum of all equipment stats.
        combineStatEffects(char_stats, sum_eqpt_stats);
    }

    ///@notice This function sums up all of the equipment's stat effects.
    function getEquipmentsEffects(uint256 character_id) internal view returns (battle_stats memory sum_eqpt_stats){
        character_equipments memory char_eqpts = equipment_manager.equippedWith(character_id);
        combineEqptEffects(sum_eqpt_stats, equipments.stats(char_eqpts.headgear));
        combineEqptEffects(sum_eqpt_stats, equipments.stats(char_eqpts.armor));
        combineEqptEffects(sum_eqpt_stats, equipments.stats(char_eqpts.weapon));
        combineEqptEffects(sum_eqpt_stats, equipments.stats(char_eqpts.accessory));
    }

    ///@notice This function combines the stat effects of 2 set of equipment stats by directly mutating the first set.
    function combineEqptEffects(battle_stats memory stats1, battle_stats memory stats2) internal pure{
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
    function combineStatEffects(battle_stats memory stats1, battle_stats memory stats2) internal pure{
        stats1.atk += stats2.atk;
        stats1.def += stats2.def;
        stats1.eva += stats2.eva;
        stats1.hp += stats2.hp;
        stats1.pen += stats2.pen;
        stats1.crit += stats2.crit;
        stats1.luck += stats2.luck;
        stats1.energy_regen += stats2.energy_regen;
    }

    ///@notice Simulate the actual battle using the character and enemy stats.
    function simulateBattle(
        character_properties memory char_props,
        battle_stats memory char_stats,
        enemy_properties memory enem_props,
        battle_stats memory enem_stats,
        uint256[] memory random_nums
        ) internal pure returns (uint256 battle_result){
        ///Initiate a variable to serve as counter for how many back and forth attacks happened (character attacks -> enemy & enemy attacks -> character)
        uint256 clashCount;

        ///Loop through the uint256[] random_nums to be consumed all throughout the series of clashes
        for(uint256 i = 1; i < 11; i++){
            ///Every main loop iteration, break the current random_num into uint16s using the loop's index.
            uint16[] memory rnums = BreakdownUint256.break256BitsIntegerIntoBytesArrayOf16Bits(random_nums[i]);

            ///For every main loop iteration, consume all 16 uint16s within two (2) sub-loops.
            ///These sub-loops will consume 8 uint16s per iteration (4 uint16s per attack from either battling party).
            for(uint256 c = 0; c < 16; c+=8){
                ///Increment the clash counter
                clashCount++;
                ///Check if the battle hasn't ended yet.
                if(char_stats.hp > 0 && enem_stats.hp > 0 && clashCount <= 20){
                    ///Apply character's damage to enemy's defense & hp effectively consuming 4 uint16 random numbers.
                    ///The first random number would be used to determine whether the attack would be evaded.
                    ///The second random number would be used to determine the actual attack damage within the character's damage range (min and max damage).
                    ///The third random number would be used to determine whether the attack would penetrate (slice through defense).
                    ///The fourth random number would be used to determine whether the attack would deal critical damage.
                    attack(char_props.character_class, char_stats, enem_stats, [rnums[c], rnums[c+1], rnums[c+2], rnums[c+3]]);
                    ///Apply enemy's damage to character's defense & hp effectively consuming 4 uint16 random numbers.
                    attack(enem_props._type, enem_stats, char_stats, [rnums[c+4], rnums[c+5], rnums[c+6], rnums[c+7]]);
                }else{
                    ///In case the number of clash instances reached 20 times and both still have remaining hp left, the battle comes to a draw.
                    if(char_stats.hp > 0 && enem_stats.hp > 0 && clashCount > 20){battle_result = 2;}

                    ///In case the battlers get both hp to 0 within the same clash instance, the battle also comes to a draw.
                    if(char_stats.hp ==0 && enem_stats.hp == 0){battle_result = 2;}

                    ///Case where the character wins.
                    if(char_stats.hp > 0 && enem_stats.hp == 0){battle_result = 1;}

                    ///Case were the character loses.
                    if(char_stats.hp == 0 && enem_stats.hp > 0){battle_result = 0;}
                }
            }
        }
    }

    ///@notice Calculate the damage dealt and taken by the battlers in each attack.
    function attack(uint256 attacker_class, battle_stats memory attacker, battle_stats memory defender, uint16[4] memory random_numbers) internal pure {
        uint256 damage;
        bool penetrated;
        bool critical_hit;
        bool evaded = evade(random_numbers[0], defender);
        if(!evaded){
            damage = getDamage(random_numbers[1], attacker, attacker_class);
        }
    }

    ///@notice Determine the actual attack damage within the attacker's damage range
    function getDamage(uint16 random_num_damage, battle_stats memory attacker, uint256 attacker_class) internal pure returns (uint256 damage){
        (uint256 minMultiplier, uint256 maxMultiplier) = getMinMaxDmg(attacker_class);
        uint256 minDamage = (minMultiplier * attacker.atk) / 1000;
        uint256 maxDamage = (maxMultiplier * attacker.atk) / 1000;
        uint256 damageSpread = maxDamage - minDamage;
        uint256 damage_roll = random_num_damage % 1000;
        uint256 damageOverMin = (damageSpread * damage_roll) / 1000;
        damage = BattleMath.safeAddUint256(minDamage, damageOverMin, maxDamage);
    }

    ///@notice Determine minimum and maximum attack damage of a specified character/enemy class/type.
    function getMinMaxDmg(uint256 attacker_class) internal pure returns (uint256 min, uint256 max){
        if(attacker_class == 0){min = 650; max = 1350;} ///Viking
        if(attacker_class == 0){min = 700; max = 1250;} ///Woodcutter
        if(attacker_class == 0){min = 750; max = 1100;} ///Troll
        if(attacker_class == 0){min = 800; max = 1050;} ///Mechanic
        if(attacker_class == 0){min = 850; max = 1000;} ///Amphibian
        if(attacker_class == 0){min = 900; max = 950;} ///Graverobber
    }

    ///@notice Determine if the attack would be evaded
    function evade(uint16 random_num_evade, battle_stats memory defender) internal pure returns (bool evaded){
        uint256 evade_roll = random_num_evade % 1000;
        if(evade_roll <= defender.eva){evaded = true;}
    }

    ///@notice Update the character properties in the Character NFT contract.
    function applyCharacterEffects(battle_request memory request, uint16 random_num_loot) internal {

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